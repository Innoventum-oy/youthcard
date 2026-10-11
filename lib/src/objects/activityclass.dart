class ActivityClass {
  int? id;
  String? name;
  String? description;
  String? coverpicture;
  String? coverpictureurl;
  int accesslevel;

  ActivityClass({
    this.id,
    this.name,
    this.description,
    this.coverpicture,
    this.coverpictureurl,
    this.accesslevel = 0,
  });

  factory ActivityClass.fromJson(Map<String, dynamic> response) {
    final responseData = Map<String, dynamic>.from(
      response['data'] ?? response,
    );
    final cover = responseData['coverpicture'];
    final rawId = responseData['objectid'] ?? responseData['id'];
    final rawAccess = responseData['accesslevel'];
    return ActivityClass(
      id: rawId == null ? null : int.tryParse(rawId.toString()),
      name: responseData['name'],
      description: responseData['description'],
      coverpicture: cover is Map
          ? cover['objectid']?.toString()
          : cover?.toString() ?? 'default',
      coverpictureurl: responseData['coverpictureurl'] is String
          ? responseData['coverpictureurl'] as String
          : null,
      accesslevel: rawAccess is int
          ? rawAccess
          : int.tryParse(rawAccess?.toString() ?? '') ?? 0,
    );
  }

  Map toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'coverpicture': coverpicture,
    'coverpictureurl': coverpictureurl,
    'accesslevel': accesslevel,
  };
}
