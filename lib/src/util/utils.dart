import 'package:feedback/feedback.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/providers/webpageprovider.dart';
import 'package:youth_card/src/util/api_client.dart';
enum LoadingState { DONE, LOADING, WAITING, ERROR }

final dollarFormat = NumberFormat("#,##0.00", "en_US");
final sourceFormat = DateFormat('yyyy-MM-dd');
final dateFormat = DateFormat.yMMMMd("en_US");

Widget getInitials(user) {
  String initials = '';
  if (user.firstname!= null && user.firstname.isNotEmpty) initials += user.firstname[0];
  if (user.lastname != null && user.lastname!.isNotEmpty) initials += user.lastname[0];
  return Text(initials);
}
String concatListToString(List<dynamic> data, String mapKey) {
  StringBuffer buffer = StringBuffer();
  buffer.writeAll(data.map<String>((map) => map[mapKey]).toList(), ", ");
  return buffer.toString();
}

String formatSeasonsAndEpisodes(int numberOfSeasons, int numberOfEpisodes) =>
    '$numberOfSeasons Seasons and $numberOfEpisodes Episodes';

String formatNumberToDollars(int amount) => '\$${dollarFormat.format(amount)}';

String formatDate(String date) {
  try {
    return dateFormat.format(sourceFormat.parse(date));
  } catch (exception) {
    return "";
  }
}

String formatRuntime(int runtime) {
  int hours = runtime ~/ 60;
  int minutes = runtime % 60;

  return '$hours\h $minutes\m';
}

launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}
Future<File> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  //return screenshotFilePath;
  return screenshotFile;
}
Future<void> feedbackAction(BuildContext context, User user) async {

  String appName = '';

  String version = '';


   await PackageInfo.fromPlatform().then((PackageInfo packageInfo){
      appName = packageInfo.appName;
      version = packageInfo.version;

    });

  final ApiClient _apiClient = ApiClient();
  BetterFeedback.of(context).show((UserFeedback feedback) async{
          Map<String,dynamic> params={
            'method' :'json',
            'modulename' :'feedback',
            'moduletype' :'pages',
            'action' :'saveobject',
            'api_key': user.token
          };
          final screenshotFile =
          await writeImageToStorage(feedback.screenshot);
          Map<String,dynamic> data = {
            'objecttype' :'feedback',
            'objectid' :'create',
            'data_email' : user.email,
            'data_phone' :user.phone,
            'data_sender' : user.lastname!+' '+user.firstname!,
            'data_subject':appName+' '+version+' '+AppLocalizations.of(context)!.feedback,
            'data_content': feedback.text,
            'file_file': screenshotFile
          };
          _apiClient.sendFeedback(params,data)!.then((var response) async {
            switch (response['status']) {
              case 'success':
                showDialog<String>(
                    context: context,
                    builder:(BuildContext context) =>AlertDialog(
                      title: Text(AppLocalizations.of(context)!.feedbackSent),
                      content: Text(AppLocalizations.of(context)!.thankyouForFeedback),

                      actions:<Widget>[
                        ElevatedButton(
                          child: Text(AppLocalizations.of(context)!.ok),
                          onPressed:() => Navigator.pop(context, 'Ok'),
                        )
                      ],
                    )
                );
            }
            if(response['error']!=null)
              handleNotifications([response['error']], context);
          });
        });
      }

Future<List<WebPage>> loadPages(BuildContext context, String commonname,user) async {

  List<WebPage> pages = [];

  final Map<String, String> params = {

    'language' : Localizations.localeOf(context).toString(),
    'commonname': commonname,
    'fields' :'id,commonname,pagetitle,textcontents',
    if(user.token!=null) 'api_key': user.token,

  };

  try {
    var result = await Provider.of<WebPageProvider>(context).loadItems(params);

      pages.addAll(result);

  } catch (e, stack) {

    String errormessage = e.toString();

    }
    return pages;
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

MaterialColor createMaterialColor(hexcode) {
  List strengths = <double>[.05];
  Map<int,Color> swatch = <int, Color>{};
  Color sourceColor = HexColor.fromHex(hexcode);
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    swatch[(strength * 1000).round()] =  sourceColor  ;

  });
  return MaterialColor(sourceColor.value, swatch);
}