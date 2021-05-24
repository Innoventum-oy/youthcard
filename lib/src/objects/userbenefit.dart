import 'package:intl/intl.dart';

class UserBenefit {
  int? id;
  String? name;
  String? description;

  DateTime? expirationdate;

  String? icon;
  String? iconurl;

  int accesslevel;

  UserBenefit(
      {this.id,
      this.name,
      this.description,
      this.expirationdate,
      this.icon,
      this.iconurl,
      this.accesslevel = 0});

  factory UserBenefit.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> responseData = response['data'];

    Map<String, dynamic>? icon = responseData['icon'] ?? null;
    if (int.parse(responseData['accesslevel']) > 10) {
      responseData.forEach((key, value) {
        print('$key = $value');
      });
    }
    return UserBenefit(
        id: responseData['objectid'] != null
            ? int.parse(responseData['objectid'])
            : null,
        name: responseData['name'],
        description: responseData['description'],

        expirationdate: responseData['expiration'] != null
            ? DateFormat('dd.MM.yyyy HH:mm:ss').parse(responseData['expirationdate'])
            : null,


        icon: icon == null ? 'default' : icon['objectid'],
        iconurl: responseData['iconurl'],

        accesslevel: responseData['accesslevel'] is int ? responseData['accesslevel'] : int.parse(responseData['accesslevel'])
    );
  }

  Map toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'expirationdate': expirationdate,
        'icon': icon,
        'iconurl': iconurl,
      };
}
