class WebPage{

  int? id;
  String? pagetitle;
  String? commonname;
  List? textcontents;

  WebPage({this.id, this.pagetitle, this.commonname, this.textcontents});

  factory WebPage.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> map = response['data'] ?? response;
    map.forEach((key, value) { print('$key = $value');});
    return WebPage(
      id: int.parse(map['id'] )as int,
      pagetitle: map['pagetitle'] ?? '' as String,
      commonname: map['commonname']  ??''as String,
      textcontents: map['textcontents'] ??'' as List,
    );
  }


  WebPage copyWith({
    int? id,
    String? pagetitle,
    String? commonname,
    List? textcontents,
  }) {
    return WebPage(
      id: id ?? this.id,
      pagetitle: pagetitle ?? this.pagetitle,
      commonname: commonname ?? this.commonname,
      textcontents: textcontents ?? this.textcontents,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'pagetitle': this.pagetitle,
      'commonname': this.commonname,
      'textcontents': this.textcontents,
    };
  }

  factory WebPage.fromMap(Map<String, dynamic> map) {
    return WebPage(
      id: map['id'] as int,
      pagetitle: map['pagetitle'] as String,
      commonname: map['commonname'] as String,
      textcontents: map['textcontents'] as List,
    );
  }

}