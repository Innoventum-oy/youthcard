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
  const UserForm({super.key, this.targetUser});
  @override
  UserFormState createState() => UserFormState();

  static UserFormState? of(BuildContext context) =>
      context.findAncestorStateOfType<UserFormState>();
}

class UserFormState extends State<UserForm>{
  final formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  bool userLoaded = false;
  bool fieldsLoaded = false;
  User user = User();
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
        user = User.fromJson(userdata['data'].first['data'],description:userdata['description']);
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
        fields = fielddata;
      }

      fieldsLoaded = true;

    });
  }
  @override
  void initState(){
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
    //check if bug reporting should be displayed.
    bool isTester = false;
    if(user.data!=null) {
      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(user.fullname),
          elevation: 0.1,
          actions: [
            if(isTester) IconButton(
                icon: Icon(Icons.bug_report),
                onPressed:(){feedbackAction(context,user); }
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

    void sendForm() {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();

        Map<String,dynamic> requestData = {};
        formData.forEach((key,value){
          if(value!=null && value !='null') {
            requestData.putIfAbsent('data_$key', ()=> value);
          }
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
          if(response['objectid'] is int) {
            objectId = response['objectid'];
          }

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

    }

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
    if(fields.isNotEmpty)
    {
      Map<String,dynamic> userdata = targetUser.toMap();
      Map<String,dynamic> p = {};
      Map<String,dynamic> fields = this.fields; // targetUser.description ?? {};

      user.data!.forEach((key,value) {});
      fields['fields'].forEach((name, definition){

        input = null;
       dynamic type = (definition?['type'] ?? '').toString();

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
              formData[name] = userdata[name];
            }
            else if( user.data!.containsKey(name)) {
              //print('user data includes '+name+' with value '+user.data![name].toString());
              formData[name] = user.data![name];
            }

              switch(type) {

                case 'password':
                  // for now, do not display the password fields here
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
                  bool isChecked = formData.containsKey(name) ? (formData[name]!=false)  : false;
               if(definition?['options']!=null) {
                 List<Widget> checkboxes = [];
                 for( String option in definition?['options'])
                 {
                   if(formData[name]==null || formData[name] is! List) {
                     List<String> list = [];
                     formData[name] = list;
                   }
                   isChecked = formData[name].contains(option);
                   checkboxes.add(CheckboxListTile(
                      title:Text(option),
                       value: isChecked,
                       onChanged: (bool? value){
                         setState((){

                           if(value! && !formData[name].contains(option)) {
                             formData[name].add(option);
                           } else if(formData[name].contains(option)) {
                             formData[name].remove(option);
                           }
                         });
                       }
                   ));
                 }
                 input = Column(children:checkboxes);
               }
                else {
                 input = CheckboxListTile(
                    title : Text(definition['displayname'] ?? name),
                    value: isChecked,
                    onChanged: (bool? value){
                      setState((){
                        formData[name] = value;
                      });
                    }
                  );
               }
                  break;

                case 'truevalue':
                  input = RadioGroup(
                      element: name,
                      options: [
                        {'key':'true','value':AppLocalizations.of(context)!.optionTrue},
                        {'key':'false', 'value': AppLocalizations.of(context)!.optionFalse}
                      ] as dynamic,
                      selectedOption: formData.containsKey(name) ?formData[name] : 'true'
                  );
                  break;

                case 'radio':
                  if(definition?['options']!=null) {
                    List<dynamic> radioButtons = [];
                    if (definition?['options'] is String) { }
                    else {
                      for (String option in definition?['options']) {
                        //   bool isChecked = this.formData[name] == option;
                        radioButtons.add({'value': option, 'key': option});
                      }
                    }
                    input = RadioGroup(element: name,options:radioButtons as dynamic,selectedOption: formData[name]);
                }

                break;


                case 'file':
                // print('handling file');
                  input = ElevatedButton(
                    onPressed: () async {

                      FilePickerResult? result = await FilePicker.platform.pickFiles();

                      if(result != null) {
                        File file = File(result.files.single.path as String);
                        formData[name] = file;
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
                      value:formData.containsKey(name) && formData[name]!=null ? formData[name].toString() :'',
                      params:p
                  );

              }//end switch
              if(input!=null) {
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
  const TextFormFieldItem({super.key, required this.element, required this.value,this.params});
  @override
  TextFormFieldItemState createState() => TextFormFieldItemState();
}
class TextFormFieldItemState extends State<TextFormFieldItem>{
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
      selectedValue = value;

      UserForm.of(context)!.formData[widget.element] = value;
    });
  }
  @override
  Widget build(BuildContext context){
    //  print('building textformfield '+widget.element.id.toString()+', initialValue: '+widget.value);
    selectedValue = widget.value;
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
  const TextFieldItem({super.key, required this.element, required this.value,this.params});
  @override
  TextFieldItemState createState() => TextFieldItemState();
}

class TextFieldItemState extends State<TextFieldItem> {

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
      selectedValue = value;

      UserForm.of(context)!.formData[widget.element] = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    selectedValue = widget.value;
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

  const RadioGroup({super.key, required this.element,required this.options,this.selectedOption});

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}


class RadioGroupWidget extends State<RadioGroup> {

  // Default Radio Button Item
  dynamic selectedOptionValue;


  @override
  Widget build(BuildContext context) {
    selectedOptionValue ??= (widget.selectedOption ?? '');

    return    Column(
        children:[

          ...widget.options.map((data) => RadioListTile<dynamic>(
            title: Text("${data['value']}"),
            groupValue: selectedOptionValue,
            value: data['key'],
            onChanged: (val) {
              setState(() {
                selectedOptionValue = data['key'] ;

                UserForm.of(context)!.formData[widget.element] = data['key'];

              });
            },
          )),
        ]);


  }
}