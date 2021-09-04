import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

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

