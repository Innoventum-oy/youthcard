import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectModel;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/util/navigator.dart';

class UserForm extends StatefulWidget {
  final User? targetUser;
  UserForm(this.targetUser);
  @override
  _UserFormState createState() => new _UserFormState();
  static _UserFormState? of(BuildContext context) =>
      context.findAncestorStateOfType<_UserFormState>();
}

class _UserFormState extends State<UserForm>{
  final formKey = new GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  User user = new User();
  int? objectId;

  Map<int,dynamic> formData = {};

  _getUserInfo() async{
    UserProvider provider = UserProvider();
    await provider.loadUser(widget.targetUser!.id ?? 0, Provider.of<UserProvider>(context, listen: false).user);
    setState(() {


      this.user = provider.user;
      // this.myContacts = provider.contacts;
    });
  }
  @override
  void initState(){
    print('initing UserForm view state');
    // this.loadFormCategories();
    this.user =widget.targetUser ?? Provider.of<UserProvider>(context, listen: false).user;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      this.user = widget.targetUser as User;
      _getUserInfo();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    User user = this.user;

    bool isTester = false;
    if(user.data!=null) {

      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.targetUser!.fullname),
          elevation: 0.1,
          actions: [
            if(isTester) IconButton(
                icon: Icon(Icons.bug_report),
                onPressed:(){feedbackAction(context,this.user); }
            ),
          ]
      ),
      body: SingleChildScrollView(
        child:Form(
            key: formKey,
            child:formBody(widget.targetUser ?? new User())
        ),
      ),
    );
  }
  Widget formBody(User targetUser)
  {

    var sendForm = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();

        Map<String,dynamic> requestData = {};
        this.formData.forEach((key,value){
          requestData.putIfAbsent('element_'+key.toString(), ()=> value);
        });

        Map<String,dynamic> params={
          'method' :'json',
          'action' :'saveobject',
          'objectid' : targetUser.id.toString(),
          'objecttype' :'iuser',

          'api_key': this.user!=null ? this.user.token :null,
        };

        _apiClient.saveObject(params,requestData).then((var response) async {
          if(response['objettid'] is int)
            this.objectId = response['answersetid'];

          switch(response['status']) {
            case 'fail':
            case 'error':
              Flushbar(
                title: AppLocalizations.of(context)!.savingDataFailed,
                message: response['message'] != null ? response['message']
                    .toString() : response.toString(),
                duration: Duration(seconds: 10),
              ).show(context);

              break;

            case 'success':
              Flushbar(
                title: AppLocalizations.of(context)!.changesSaved,
                message: response['message'] != null ? response['message']
                    .toString() : AppLocalizations.of(context)!.changesSaved,
                duration: Duration(seconds: 10),
              ).show(context);


          }
        });
      } else {
        Flushbar(
          title: AppLocalizations.of(context)!.errorsInForm,
          message: AppLocalizations.of(context)!.pleaseCompleteFormProperly,
          duration: Duration(seconds: 10),
        ).show(context);

      }

    };

    var loader=Align(
      alignment: Alignment.center,
      child: Center(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text(AppLocalizations.of(context)!.loading,
              textAlign: TextAlign.center),
        ),
      ),
    );
    List<Widget> inputs = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(targetUser.fullname,
            style: Theme.of(context).textTheme.headline4),
      ),


    ];
    Widget input = Placeholder();

    if(user.description!.isNotEmpty)
    {
      Map<String,dynamic> fields = user.description ?? {};
          fields.forEach((name, type){
          //  print(e.id.toString()+': '+e.type.toString());
            //create input field matching element type

            switch(type.toString()) {
              case 'textarea':
              //print('handling textarea');
                Map<String,dynamic>p = {'maxlines':10};
                input = TextFieldItem(element: name,value:this.formData.containsKey(name) ? this.formData[name] :'',params:p);
                break;
              case 'radio':

                if(e.data!=null) {

                  input = RadioGroup(element: e,options:e.data as dynamic,selectedOption: this.formData.containsKey(e.id) ? int.parse(this.formData[e.id]) : e.data!.first.id);
                }
                else input = Text('no entry data found in '+e.data.toString());
                break;

              case 'file':
              // print('handling file');
                input = ElevatedButton(
                  onPressed: () async {

                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    if(result != null) {
                      File file = File(result.files.single.path);
                      this.formData[e.id??0] = file;
                    } else {
                      // User canceled the picker
                    }


                  },
                  child: Text(
                    AppLocalizations.of(context)!.chooseFile,
                    style: TextStyle(
                      // fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
                break;

              default:
                input = TextFieldItem(
                  element: e,
                  value:this.formData.containsKey(e.id) ? this.formData[e.id] :'',
                );

            }
            //add the input with label and surrounding element to list
            inputs.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment:Alignment.centerLeft,
                  child:Text(e.title.toString(),
                      style: Theme.of(context).textTheme.headline5),
                )
            )
            );
            inputs.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: input,
            ));
          }
        }
    return Column(
        children:[
          //  Text(form.elements.length.toString()+' elements found:'),
          ...inputs,
          longButtons(AppLocalizations.of(context)!.save, sendForm),
        ]

    );


  }

}
class TextFieldItem extends StatefulWidget{
  final FormElement element;
  final String value;
  final Map<String,dynamic>? params ;
  TextFieldItem({required this.element, required this.value,this.params});
  @override
  _TextFieldItemState createState() => _TextFieldItemState();
}

class _TextFieldItemState extends State<TextFieldItem> {

  late String selectedValue;
  final  _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    _textEditingController.addListener(updateTextFieldValue);
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _textEditingController.dispose();
    super.dispose();
  }
  void updateTextFieldValue()
  {
    String? value = _textEditingController.text;
    setState(() {
      this.selectedValue = value;

      DisplayForm.of(context)!.formData[widget.element.id!] = value;
    });
  }
  Widget build(BuildContext context) {
    this.selectedValue = widget.value;
    return TextField(
      controller: _textEditingController,
      //textDirection: TextDirection
      maxLines: widget.params!['maxlines'] ?? 10,

      decoration: InputDecoration(hintText: widget.element.description ?? AppLocalizations.of(context)!.writeAnswerHere,//+': '+widget.element.title.toString(),
          fillColor:createMaterialColor('#FFEDE30E')),
    );
  }
}
class RadioGroup extends StatefulWidget {
  final FormElement element;
  final List<dynamic> options;
  final int? selectedOption;

  RadioGroup({required this.element,required this.options,this.selectedOption});

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}


class RadioGroupWidget extends State<RadioGroup> {

  // Default Radio Button Item
  int? selectedOptionValue;


  Widget build(BuildContext context) {
    this.selectedOptionValue = (widget.selectedOption ?? '') as int?;
    print('building radio group; group value is '+selectedOptionValue.toString());

    return    Container(
      //height: 350.0,
      child: Column(
          children:[
            if(widget.element.description != null)Text(widget.element.description ?? ''),
            ...widget.options.map((data) => RadioListTile<dynamic>(
              title: Text("${data.value}"),
              groupValue: selectedOptionValue,
              value: data.id,
              onChanged: (val) {
                setState(() {
                  print('selecting: '+data.value.toString()+' ('+data.id.toString()+')');
                  this.selectedOptionValue = data.id ;


                  DisplayForm.of(context)!.formData[widget.element.id??0] = data.id;

                });
              },
            )).toList(),
          ]),
    );


  }
}