class WebPage{

  int? id;
  String? pagetitle;
  String? commonname;
  List? textcontents;
  Map<String,dynamic>? data;

  WebPage({this.id, this.pagetitle, this.commonname, this.textcontents, this.data});

  factory WebPage.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> map = response['data'] ?? response;
    //map.forEach((key, value) { print('$key = $value');});
    return WebPage(
      id: int.parse(map['id'] ),
      pagetitle: map['pagetitle'] ?? '' ,
      commonname: map['commonname']  ??'',
      textcontents: map['textcontents'] ??'' ,
        data: map
    );
  }


  WebPage copyWith({
    int? id,
    String? pagetitle,
    String? commonname,
    List? textcontents,
    Map<String,dynamic>? data,
  }) {
    return WebPage(
      id: id ?? this.id,
      pagetitle: pagetitle ?? this.pagetitle,
      commonname: commonname ?? this.commonname,
      textcontents: textcontents ?? this.textcontents,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'pagetitle': this.pagetitle,
      'commonname': this.commonname,
      'textcontents': this.textcontents,
      'data' :this.data,
    };
  }

  factory WebPage.fromMap(Map<String, dynamic> map) {
    return WebPage(
      id: map['id'] as int,
      pagetitle: map['pagetitle'] as String,
      commonname: map['commonname'] as String,
      textcontents: map['textcontents'] as List,
      data : map,
    );
  }

}