import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important
class MetaSection extends StatelessWidget {
  final dynamic data;

  MetaSection(this.data);

  @override
  Widget build(BuildContext context) {
 // print(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.about,
          style: TextStyle(color: Colors.white),
        ),
        Container(
          height: 8.0,
        ),
        data['data']['contactinfo'].toString().length>0? _parseHtml(data['data']['contactinfo']?? ''):Container(),
        _getSectionOrContainer(AppLocalizations.of(context)!.address,'address',),
        _getSectionOrContainer(AppLocalizations.of(context)!.postcode,'postcode'),
        _getSectionOrContainer(AppLocalizations.of(context)!.city,'city'),

      /*  _getSectionOrContainer('Original Title', 'original_name'),
        _getSectionOrContainer('Status', 'status'),
        _getSectionOrContainer('Runtime', 'runtime',
            formatterFunction: formatRuntime),
        _getCollectionSectionOrContainer('Type', 'genres', 'name'),
        _getCollectionSectionOrContainer('Creators', 'created_by', 'name'),
        _getCollectionSectionOrContainer('Networks', 'networks', 'name'),
        (data['number_of_seasons'] != null &&
            data['number_of_episodes'] != null)
            ? _getMetaInfoSection(
            'Seasons',
            formatSeasonsAndEpisodes(
                data['number_of_seasons'], data['number_of_episodes']))
            : Container(),
        _getSectionOrContainer('Premiere', 'release_date',
            formatterFunction: formatDate),
        _getSectionOrContainer('Premiere', 'first_air_date',
            formatterFunction: formatDate),
        _getSectionOrContainer('Latest/Next Episode', 'last_air_date',
            formatterFunction: formatDate),
        _getSectionOrContainer('Budget', 'budget',
            formatterFunction: formatNumberToDollars),
        _getSectionOrContainer('Revenue', 'revenue',
            formatterFunction: formatNumberToDollars),
        _getSectionOrContainer('Homepage', 'homepage', isLink: true),
        _getSectionOrContainer('Imdb', 'imdb_id',
            formatterFunction: getImdbUrl, isLink: true),*/
      ],
    );
  }

  Widget _getCollectionSectionOrContainer(
      String title, String listKey, String mapKey) {
    return data[listKey] == null
        ? Container()
        : _getMetaInfoSection(title, concatListToString(data[listKey], mapKey));
  }

  Widget _getSectionOrContainer(String title, String content,
      {dynamic formatterFunction, bool isLink: false}) {


    print('_getSectionOrContainer called with title '+title+', content '+content);
   // print('value is:'+data[content].toString());
    data.forEach((key, value) {print('$key = $value');});
    print('--DATA--');
    data['data'].forEach((key, value) {print('$key = $value');});
    return data['data'][content] == null
        ? Container()
        : _getMetaInfoSection(
        title,
        (formatterFunction != null
            ? formatterFunction(data['data'][content])
            : data['data'][content]),
        isLink: isLink);
  }
  Widget _parseHtml(content){
    print('returning parsed content for '+content.toString());
    return Html(
        data: content,
      style: {"*" : Style(color:Colors.white)}
    );
  }
  Widget _getMetaInfoSection(String title, String content,
      {bool isLink: false}) {
    if (content == null) return Container();
    print('getMetaInfoSection called for '+title);
    var contentSection = Expanded(
      flex: 4,
      child: GestureDetector(
        onTap: () => isLink ? launchUrl(content) : null,
        child: Text(
          content,
          style: TextStyle(
              color: isLink ? Colors.blue : Colors.white, fontSize: 12.0),
        ),
      ),
    );

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                '$title:',
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              ),
            ),
            contentSection
          ],
        ));
  }
}