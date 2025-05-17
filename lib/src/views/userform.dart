import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';


class UserForm extends StatefulWidget {
  final User? targetUser;
  UserForm({this.targetUser});
  @override
  _UserFormState createState() => new _UserFormState();
  static _UserFormState? of(BuildContext context) =>
      context.findAncestorStateOfType<_UserFormState>();
}

class _UserFormState extends State<UserForm>{
  final formKey = new GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  bool userLoaded = false;
  bool fieldsLoaded = false;
  User user = new User();
  int? objectId;
  Map<String,dynamic> fields = {};
  Map<String,dynamic> formData = {};

  /*
  Returns user information from server
   */
  _getUserInfo() async{

    UserProvider provider = UserProvider();
    //target user:
    int targetId = widget.targetUser?.id ?? (Provider.of<UserProvider>(context, listen: false).user.id ?? 0);
  //  print('_getUserInfo called, retrieving user information from userprovider for user '+targetId.toString());
    dynamic userdata = await provider.getObject(targetId, Provider.of<UserProvider>(context, listen: false).user);
    setState(() {

      if(userdata!=null) {
        this.user = User.fromJson(userdata['data'].first['data'],description:userdata['description']);
      //  print('user loaded by provider!');
      }
     // else print('No userdata returned by provider!!');
      userLoaded = true;
      // this.myContacts = provider.contacts;
    });
  }

  /// Returns available fields information from server
  _getFields() async{

    UserProvider provider = UserProvider();
    //target user:
    int targetId = widget.targetUser?.id ?? (Provider.of<UserProvider>(context, listen: false).user.id ?? 0);
    //  print('_getUserInfo called, retrieving user information from userprovider for user '+targetId.toString());
    dynamic fielddata = await provider.getFields(targetId, Provider.of<UserProvider>(context, listen: false).user);
    setState(() {

      if(fielddata!=null) {
        this.fields = fielddata;
      }

      fieldsLoaded = true;

    });
  }
  @override
  void initState(){
    print('initing UserForm view state');
    // this.loadFormCategories();
    //this.user = Provider.of<UserProvider>(context, listen: false).user;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getUserInfo();
      _getFields();
    });
    super.initState();
  }
  Widget loader(context){
    return Align(
      alignment: Alignment.center,
      child: Center(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text(AppLocalizations.of(context)!.loading,
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context)
  {
    print('build called for userform');
    //check if bug reporting should be displayed.
    bool isTester = false;
    if(this.user.data!=null) {
      if (this.user.data!['istester'] != null) {
        if (this.user.data!['istester'] == 'true') isTester = true;
      }
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(this.user.fullname),
          elevation: 0.1,
          actions: [
            if(isTester) IconButton(
                icon: Icon(Icons.bug_report),
                onPressed:(){feedbackAction(context,this.user); }
            ),
          ]
      ),
      body: SingleChildScrollView(
        child:userLoaded && fieldsLoaded ? Form(
            key: formKey,
            child:formBody(user)
        ) : loader(context),
      ),
    );
  }//end build

  Widget formBody(User targetUser)
  {

    var sendForm = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();

        Map<String,dynamic> requestData = {};
        this.formData.forEach((key,value){
          if(value!=null && value !='null')
          requestData.putIfAbsent('data_'+key.toString(), ()=> value);
        });

        Map<String,dynamic> params={
          'method' :'json',
          'action' :'saveobject',
          'modulename' :'registration',
          'moduletype' :'pages',
          'objectid' : targetUser.id.toString(),
          'objecttype' :'iuser',
          'api_key': Provider.of<UserProvider>(context, listen: false).user.token,
        };

        _apiClient.saveObject(params,requestData).then((var response) async {
          if(response['objectid'] is int)
            this.objectId = response['objectid'];

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

    //loading symbol display


    List<Widget> inputs = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(targetUser.fullname,
            style: Theme.of(context).textTheme.headlineSmall),
      ),

    ];

    Widget? input ;

    //if(targetUser.description!=null)
    if(this.fields.length>0)
    {
      Map<String,dynamic> userdata = targetUser.toMap();
      Map<String,dynamic> p = {};
      Map<String,dynamic> fields = this.fields; // targetUser.description ?? {};
      int elementNumber = 1;
      //print('USERDATA');
      //print(userdata.toString());
      user.data!.forEach((key,value) {print(key.toString()+':'+value.toString());});
      print(user.data.toString());
      fields['fields'].forEach((name, definition){

        input = null;
       dynamic type = (definition?['type'] ?? '').toString();
          //  print(e.id.toString()+': '+e.type.toString());
            //create input field matching element type
            /*
            * possible types:
            *   textline
            *   text
            *   date
            *   datetime
            *   int unsigned
            *   truevalue
            *   radio
            *   number
            *   object  - currently unsupported
            *   tel
            *   file
             */
            //reset params
            p = {};



            if(userdata.containsKey(name)) {
            //  print('user has own property '+name+' with value '+userdata[name].toString());
              this.formData[name] = userdata[name];
            }
            else if( user.data!.containsKey(name)) {
              //print('user data includes '+name+' with value '+user.data![name].toString());
              this.formData[name] = user.data![name];
            }
            else print('no data found for '+name);
              print('Element $elementNumber '+name+' has type '+type+', value '+this.formData[name].toString());
              elementNumber++;
              switch(type) {

                case 'password':
                  // for now, do not display the password fields here
                print('not displaying the element '+name);
                  break;

                case 'textline':
                case 'text':
                p['maxlines'] = 1;
                continue printdefaultinput;

                case 'textarea':
                //define parameters
                  p['maxlines'] = 10;
                  continue printdefaultinput;


              /**
               * true/false value radio input
               */

                case 'checkbox' :
                  bool isChecked = this.formData.containsKey(name) ? (this.formData[name]!=false)  : false;
               if(definition?['options']!=null) {
                 print('options: ' +
                     (definition?['options'].length > 0 ? definition['options']
                         .toString() : ''));
                 List<Widget> checkboxes = [];
                 for( String option in definition?['options'])
                 {
                   if(this.formData[name]==null || !(this.formData[name] is List)) {
                     print('creating empty list container for '+name);
                     List<String> list = [];
                     this.formData[name] = list;
                   }
                   isChecked = this.formData[name].contains(option);
                   checkboxes.add(CheckboxListTile(
                      title:Text(option),
                       value: isChecked,
                       onChanged: (bool? value){
                         setState((){

                           if(value! && !this.formData[name].contains(option)) this.formData[name].add(option);
                           else if(this.formData[name].contains(option)) this.formData[name].remove(option);
                         });
                       }
                   ));
                 }
                 input = Column(children:checkboxes);
               }
                else  input = CheckboxListTile(
                    title : Text(definition['displayname'] ?? name),
                    value: isChecked,
                    onChanged: (bool? value){
                      setState((){
                        this.formData[name] = value;
                      });
                    }
                  );
                  break;

                case 'truevalue':
                  input = RadioGroup(
                      element: name,
                      options: [
                        {'key':'true','value':AppLocalizations.of(context)!.optionTrue},
                        {'key':'false', 'value': AppLocalizations.of(context)!.optionFalse}
                      ] as dynamic,
                      selectedOption: this.formData.containsKey(name) ?this.formData[name] : 'true'
                  );
                  break;

                case 'radio':
                  if(definition?['options']!=null) {
                    print('options: ' +
                        (definition?['options'].length > 0 ? definition['options']
                            .toString() : ''));
                    List<dynamic> radioButtons = [];
                    if (definition?['options'] is String) { }
                    else
                    for( String option in definition?['options']) {
                   //   bool isChecked = this.formData[name] == option;
                      radioButtons.add({'value':option,'key':option});
                    }
                    input = RadioGroup(element: name,options:radioButtons as dynamic,selectedOption: this.formData[name]);
                }

                break;


                case 'file':
                // print('handling file');
                  input = ElevatedButton(
                    onPressed: () async {

                      FilePickerResult? result = await FilePicker.platform.pickFiles();

                      if(result != null) {
                        File file = File(result.files.single.path as String);
                        this.formData[name] = file;
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

                case 'tel':
                  p['keyboardtype'] = TextInputType.phone;
                  continue printdefaultinput;

                case 'number':
                  p['keyboardtype'] = TextInputType.number;
                  continue printdefaultinput;

                printdefaultinput:
                default:

                  input = TextFormFieldItem(
                      element: name,
                      value:this.formData.containsKey(name) && this.formData[name]!=null ? this.formData[name].toString() :'',
                      params:p
                  );

              }//end switch
              if(input!=null) {
                print(input.toString());
                //add the input with label and surrounding element to list
                inputs.add(
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(definition['displayname'] ?? name,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineSmall),
                        )
                    )
                );

                inputs.add(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: input,
                )
                );
              }
            }//foreach field
          );
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

class TextFormFieldItem extends StatefulWidget{
  final String element;
  final String value;
  final Map<String,dynamic>? params ;
  TextFormFieldItem({required this.element, required this.value,this.params});
  _TextFormFieldItemState createState() => _TextFormFieldItemState();
}
class _TextFormFieldItemState extends State<TextFormFieldItem>{
  late String selectedValue;
  final  _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // print('textformfield initialValue in initState: '+widget.value);
    // Start listening to changes.
    _textEditingController.text = widget.value;
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
    //  print('running updateTextFieldValue, value: '+value);
    setState(() {
      this.selectedValue = value;

      UserForm.of(context)!.formData[widget.element] = value;
    });
  }
  Widget build(BuildContext context){
    //  print('building textformfield '+widget.element.id.toString()+', initialValue: '+widget.value);
    this.selectedValue = widget.value;
    return TextFormField(
        autovalidateMode: AutovalidateMode.always,
        controller: _textEditingController,
        // initialValue: widget.value,
        maxLines: widget.params!['maxlines'] ?? 1,
        keyboardType : widget.params?['keyboardtype'] ?? TextInputType.text,
        validator: (String? value){

          if(widget.params!=null && widget.params!['required']!=null) {
            return value != null ? null : AppLocalizations.of(context)!
                .fieldCannotBeEmpty;
          }
            return null;


        }
    );
  }
}

class TextFieldItem extends StatefulWidget{
  //final FormElement
  final String element;
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

      UserForm.of(context)!.formData[widget.element] = value;
    });
  }
  Widget build(BuildContext context) {
    print('textfield has value '+widget.value.toString());
    this.selectedValue = widget.value;
    return TextField(
      controller: _textEditingController,
      //textDirection: TextDirection
      maxLines: widget.params?['maxlines'] ?? 1,
      keyboardType : widget.params?['keyboardtype'] ?? TextInputType.text
    );
  }
}
class RadioGroup extends StatefulWidget {
  final String element;
  final List<dynamic> options;
  final dynamic selectedOption;

  RadioGroup({required this.element,required this.options,this.selectedOption});

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}


class RadioGroupWidget extends State<RadioGroup> {

  // Default Radio Button Item
  dynamic selectedOptionValue;


  Widget build(BuildContext context) {
    if(this.selectedOptionValue==null)
    this.selectedOptionValue = (widget.selectedOption ?? '') ;
    print('building radio group '+widget.element+'; value is '+selectedOptionValue.toString());

    return    Container(
      //height: 350.0,
      child: Column(
          children:[

            ...widget.options.map((data) => RadioListTile<dynamic>(
              title: Text("${data['value']}"),
              groupValue: selectedOptionValue,
              value: data['key'],
              onChanged: (val) {
                setState(() {
                  print('selecting: '+data['value'].toString()+' ('+data['key'].toString()+')');
                  this.selectedOptionValue = data['key'] ;

                  UserForm.of(context)!.formData[widget.element] = data['key'];

                });
              },
            )).toList(),
          ]),
    );


  }
}