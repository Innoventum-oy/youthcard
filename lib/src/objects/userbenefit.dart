import 'package:intl/intl.dart';

class UserBenefit {
  int? id;
  String? title;
  String? description;

  DateTime? expirationdate;

  Map<String, dynamic>? icon;
  String? iconurl;

  int accesslevel;

  UserBenefit(
      {this.id,
      this.title,
      this.description,
      this.expirationdate,
      this.icon,
      this.iconurl,
      this.accesslevel = 0});

  factory UserBenefit.fromJson(Map<String, dynamic> responseData) {
    //Map<String, dynamic> responseData = response['data'];


    /*if (( responseData['accesslevel'] is int ? responseData['accesslevel'] : int.parse(responseData['accesslevel'])) > 10) {
      responseData.forEach((key, value) {
        print('$key = $value');
      });
    }

     */
    return UserBenefit(
        id: responseData['objectid'] != null
            ? int.parse(responseData['objectid'])
            : null,
        title: responseData['title'],
        description: responseData['description'],

        expirationdate: responseData['expiration'] != null
            ? DateFormat('dd.MM.yyyy HH:mm:ss').parse(responseData['expirationdate'])
            : null,


        icon:  responseData['icon'],
        iconurl: responseData['iconurl'],

        accesslevel: responseData['accesslevel'] is int ? responseData['accesslevel'] : int.parse(responseData['accesslevel'])
    );
  }

  Map toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'expirationdate': expirationdate,
        'icon': icon,
        'iconurl': iconurl,
      };
}
