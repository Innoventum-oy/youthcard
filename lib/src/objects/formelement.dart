class FormElement{
  int? id;
  int? tab;
  int? position;
  String? type;
  String? title;
  bool required;
  String? help;
  String? description;
  //String? answer;
  int? notecount;
  List<FormElementData>? data;

  FormElement({
    this.id,
    this.tab,
    this.position,
    this.type,
    this.title,
    this.required =false,
    this.help,
    this.description,
    // this.answer,
    this.notecount,
    this.data
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tab': tab,
      'position': position,
      'type': type,
      'title': title,
      'required': required,
      'help': help,
      'description': description,
      //'answer': this.answer,
      'notecount': notecount,

    };
  }

  factory FormElement.fromJson(Map<String, dynamic> map) {
    //print(response);
    //Map<String, dynamic> map = response['data'] ?? response;
    return FormElement(
      id: int.parse(map['id']),
      tab: int.parse(map['tab']),
      position: int.parse(map['position']),
      type: map['type'] as String,
      title: map['title'] as String,
      required: map['required'] as bool,
      help: map['help']!=null ?map['help'] as String :null,
      description: map['description']!=null ? map['description'] as String:null,
      // answer:map['answer']!=null ? map['answer'] as String: null,
      notecount:  map['notecount'] is int ? map['notecount'] :int.parse(map['notecount']),
      data : map['data']?.map<FormElementData>((data) => FormElementData.fromJson(data))
          .toList(),
    );
  }
}

class FormElementData{
  int? id;
  int? score;
  String? value;
  String? imageurl;
  int? position;

  FormElementData({this.id,this.score,this.value,this.imageurl,this.position});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'value': value,
      'imageurl': imageurl,
      'position': position,
    };
  }

  factory FormElementData.fromJson(Map<String, dynamic> map) {
    return FormElementData(
      id: int.parse(map['id']),
      score: map['score']!=null ?int.parse(map['score']) :0,
      value: map['value'] as String,
      imageurl: map['imageurl'] != false && map['imageurl']!=null ? map['imageurl'] as String : null,
      position: int.parse(map['position']),

    );
  }
}