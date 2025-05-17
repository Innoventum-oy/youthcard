import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/formelement.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/index.dart' as object_model;
import 'package:youth_card/src/objects/form.dart' as icms_form;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'formlist.dart';

class DisplayForm extends StatefulWidget {
  final object_model.FormElementProvider formElementProvider =
      object_model.FormElementProvider();
  final icms_form.Form form;

  DisplayForm(this.form, {super.key});

  @override
  DisplayFormState createState() => DisplayFormState();

  static DisplayFormState? of(BuildContext context) =>
      context.findAncestorStateOfType<DisplayFormState>();
}

class DisplayFormState extends State<DisplayForm> {
  final formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  User? user;
  bool elementsLoaded = false;
  bool answersLoaded = false;
  Map<int, FormElementData> selectedOptions = {};
  int? answersetKey;
  Map<int, dynamic> formData = {};

  Future<void> loadElements(form) async {
    elementsLoaded = true;
    // print('loadElements called for form '+form.title+' which has status '+form.loadingStatus.toString());

    Map<String, dynamic> params = {
      'api_key': user?.token,
    };

    params['formid'] = form.id.toString();
    if (form.loadingStatus == icms_form.LoadingStatus.idle) {
      form.loadingStatus = icms_form.LoadingStatus.loading;
      dynamic result = await widget.formElementProvider.getElements(params);

      setState(() {
        //     print(result.length.toString() + ' elements found for form ' + form.title);
        form.loadingStatus = icms_form.LoadingStatus.ready;
        form.elements.clear();
        for (var i in result) {
          form.elements.add(i);
        }
        //if(result.isNotEmpty()) form.elements.addAll(result);
        loadAnswers(form);
      });
    }
  }

  Future<void> loadAnswers(form) async {

    Map<String, dynamic> params = {
      'formid': form.id.toString(),
      'action': 'loadanswers',
      'method': 'json',
      'api_key': user?.token,
    };

    _apiClient.loadFormData(params)!.then((responseData) {
      setState(() {
        answersLoaded = true;
        if(responseData['answersetkey']!=null) {

          answersetKey = int.parse(responseData['answersetkey']);
        }
          var response = responseData['data'];
          //    print(response.toString());
          if (response != null) {
            response.forEach(( key, data) {

              int eid = data['formelementid'] is int ? data['formelementid'] : int.parse(data['formelementid']);
              if(data['answer']!=null) {
                dynamic answer;

                try {
                  answer = json.decode(data['answer']);
                } on FormatException {
                  answer = data['answer'];
                }
                if (data['answertype'] == 'checkbox') {
                  if (formData[eid] == null || formData[eid] is! List) {
                    formData[eid] = [];
                  }
                  formData[eid].add(answer);
                }
                else {
                  formData[eid] = answer;
                }
              }
            });
          }

      });
    });
  }

  @override
  void initState() {
    //print('initing FillForm view state');
    // this.loadFormCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.form.loadingStatus = icms_form.LoadingStatus.idle;
      if (!elementsLoaded) loadElements(widget.form);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Get user provider
    user = Provider.of<UserProvider>(context).user;
    //Get current form
    icms_form.Form form = widget.form;

    //tester status sets display of bug reporting button
    bool isTester = false;
    if (user!.data != null) {
      if (user!.data!['istester'] != null) {
        if (user!.data!['istester'] == 'true') isTester = true;
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(form.title!), elevation: 0.1, actions: [
        if (isTester)
          IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: () {
                feedbackAction(context, user!);
              }),
      ]),
      body: SingleChildScrollView(
        child: Form(key: formKey, child: formBody(form)),
      ),
    );
  }

  Widget formBody(icms_form.Form form) {
    void sendForm() {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        bool hasData = false;
        Map<String, dynamic> requestData = {};
        formData.forEach((key, value) {
          if (value != null) hasData = true;
          if (value.runtimeType.toString() == 'bool' && value != false) {
            hasData = true;
          //  print('value is boolean ' + value.toString());
          }
          if (value.runtimeType.toString() == 'String' && value.isNotEmpty && value!='null') {
            hasData = true;
         //   print('value is String: ' + value);
          }
          /*
          if (hasData)
            print('formData field ' +
                key.toString() +
                ' has value ' +
                value.toString());
          else
            print('formData field ' +
                key.toString() +
                ' of type ' +
                value.runtimeType.toString() +
                ' is empty:' +
                value.toString());
                */

          if(hasData) {
            requestData.putIfAbsent('element_$key', () => value);
          }
        });

        Map<String, dynamic> params = {
          'method': 'json',
          'action': 'saveanswers',
          'formid': widget.form.id.toString(),
          'api_key': user?.token,
        };

        if (hasData) {
          _apiClient
              .saveFormData(params, requestData)!
              .then((var response) async {
            if (response['answersetid'] is int) {
              answersetKey = response['answersetid'];
            }

            switch (response['status']) {
              case 'fail':
              case 'error':
                Flushbar(
                  title: AppLocalizations.of(context)!.savingDataFailed,
                  message: response['message'] != null
                      ? response['message'].toString()
                      : response.toString(),
                  duration: Duration(seconds: 10),
                ).show(context);
                if(response['data']!=null) {
                  response['data'].forEach((key,dataset){

                });
                }
                break;

              case 'success':
                Flushbar(
                  title: AppLocalizations.of(context)!.answerSaved,
                  message: response['message'] != null
                      ? response['message'].toString()
                      : AppLocalizations.of(context)!.answerSaved,
                  duration: Duration(seconds: 10),
                ).show(context);

                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title:
                              Text(AppLocalizations.of(NavigationService.navigatorKey.currentContext ?? context)!.answerSaved),
                          content: SingleChildScrollView(
                              child: Text(
                            response['message'] != null
                                ? response['message'].toString()
                                : AppLocalizations.of(NavigationService.navigatorKey.currentContext ?? context)!.answerSaved,
                          )),
                          actions: <Widget>[
                            ElevatedButton(
                                child:
                                    Text(AppLocalizations.of(NavigationService.navigatorKey.currentContext ?? context)!.great),
                                onPressed: () {
                                  setState(() {
                                    //TODO: forward to list of available forms
                                    Navigator.of(context, rootNavigator: true).pop();
                                    Navigator.pushReplacement(
                                      NavigationService.navigatorKey.currentContext ?? context,
                                      MaterialPageRoute(builder: ( context) => FormList()),
                                    );
                                  });
                                })
                          ],
                        ));
            }
          });
        } else {
          Flushbar(
            title: AppLocalizations.of(context)!.errorsInForm,
            message: AppLocalizations.of(context)!.pleaseCompleteFormProperly,
            duration: Duration(seconds: 10),
          ).show(context);
        }
      } else {
        Flushbar(
          title: AppLocalizations.of(context)!.errorsInForm,
          message: AppLocalizations.of(context)!.pleaseCompleteFormProperly,
          duration: Duration(seconds: 10),
        ).show(context);
      }
    }

    var loader = Align(
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
        child: Text(form.title ?? '',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          form.description.toString(),
        ),
      )
    ];

    Widget input = Placeholder();

    switch (form.loadingStatus) {
      case icms_form.LoadingStatus.ready:
        if (!(answersLoaded && elementsLoaded)) return loader;
        if (form.elements.isNotEmpty) {
          Map<String,dynamic> p = {};
          for (var e in form.elements) {
            //    print(e.id.toString()+': '+e.type.toString());
            //create input field matching element type
            p = {};
            switch (e.type.toString()) {

              case 'textarea':
                //print('handling textarea');
                Map<String, dynamic> p = {'maxlines': 10};
                input = TextFormFieldItem(
                    element: e,
                    value: formData.containsKey(e.id) && formData[e.id]!=null
                        ? formData[e.id]
                        : '',
                    params: p);
                break;

              case 'radio':
                if (e.data != null) {
                  input = RadioGroup(
                      element: e,
                      options: e.data as dynamic,
                      selectedOption: formData.containsKey(e.id)
                          ? (formData[e.id] is int
                              ? formData[e.id]
                              : int.parse(formData[e.id]))
                          : null);
                } else {
                  input = Text('no entry data found in ${e.data}');
                }
                break;
              case 'checkbox' :
                bool isChecked = formData.containsKey(e.id) ? (formData[e.id]!=false)  : false;
                List<Widget> checkboxes = [];
                if(e.data!=null) {
                  for (var element in e.data!) {
           //         print(this.formData[e.id].toString());
             //       print(e.id.toString()+': '+this.formData[e.id].runtimeType.toString());
                    if(formData[e.id]==null || formData[e.id] is! List) {
                   //   print('creating empty list container for element '+e.id.toString()+' '+e.title.toString());
                      List<int> list = [];
                      if(formData[e.id]!=null) list.add(formData[e.id] is int ? formData[e.id] : int.parse(formData[e.id]));
                        formData[e.id??0] = list;
                    }

                    isChecked = formData[e.id].contains(element.id);
                    checkboxes.add(CheckboxListTile(
                        title:Text(element.value.toString()),
                        value: isChecked,
                        onChanged: (bool? value){
                          setState((){

                            if(value! && !formData[e.id].contains(element.id)) {
                              formData[e.id].add(element.id);
                            } else if(formData[e.id].contains(element.id)) {
                              formData[e.id].remove(element.id);
                            }
                          });
                        }
                    ));
                  }

                  input = Column(children:checkboxes);
                }

                break;
              case 'file':
                // print('handling file');
                input = ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      File file = File(result.files.single.path as String);
                      formData[e.id ?? 0] = file;
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
                  element: e,
                  value: formData.containsKey(e.id) && formData[e.id]!=null
                      ? formData[e.id]
                      : '',
                 params: p
                );
            }
            //add the input with label and surrounding element to list
            inputs.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(e.title.toString(),
                      style: Theme.of(context).textTheme.headlineSmall),
                )));
            inputs.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: input,
            ));
          }
        }
        return Column(children: [
          //  Text(form.elements.length.toString()+' elements found:'),
          ...inputs,
          longButtons(AppLocalizations.of(context)!.saveAnswer, sendForm),
        ]);
      default:
        if (form.loadingStatus == icms_form.LoadingStatus.idle &&
            !elementsLoaded) {
          loadElements(widget.form);
        }
        return loader;
    }
  }
}

class TextFormFieldItem extends StatefulWidget {
  final FormElement element;
  final String value;
  final Map<String, dynamic> params;

  const TextFormFieldItem({super.key, required this.element, required this.value, required this.params});

  @override
  TextFormFieldItemState createState() => TextFormFieldItemState();
}

class TextFormFieldItemState extends State<TextFormFieldItem> {
  late String selectedValue;
  final _textEditingController = TextEditingController();

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

  void updateTextFieldValue() {
    String? value = _textEditingController.text;
    //  print('running updateTextFieldValue, value: '+value);
    setState(() {
      selectedValue = value;

      DisplayForm.of(context)!.formData[widget.element.id!] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    //  print('building textformfield '+widget.element.id.toString()+', initialValue: '+widget.value);
    selectedValue = widget.value;
    return TextFormField(
        autovalidateMode: AutovalidateMode.always,
        controller: _textEditingController,
        // initialValue: widget.value,
        maxLines: widget.params['maxlines'] ?? 1,
        decoration: InputDecoration(
            hintText: widget.element.description ??
                AppLocalizations.of(context)!.writeAnswerHere,
            //+': '+widget.element.title.toString(),
            fillColor: createMaterialColor('#FFEDE30E')),
        validator: (String? value) {
          if (widget.element.required == false) {
            //   print('element is not required!');
            return null;
          }
          return value != null
              ? null
              : AppLocalizations.of(context)!.fieldCannotBeEmpty;
        });
  }
}

class TextFieldItem extends StatefulWidget {
  final FormElement element;
  final String value;
  final Map<String, dynamic>? params;

  const TextFieldItem({super.key, required this.element, required this.value, this.params});

  @override
  TextFieldItemState createState() => TextFieldItemState();
}

class TextFieldItemState extends State<TextFieldItem> {
  late String selectedValue;
  final _textEditingController = TextEditingController();

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

  void updateTextFieldValue() {
    String? value = _textEditingController.text;
    setState(() {
      selectedValue = value;

      DisplayForm.of(context)!.formData[widget.element.id!] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedValue = widget.value;
    return TextField(
      controller: _textEditingController,
      //textDirection: TextDirection
      maxLines: widget.params!['maxlines'] ?? 10,

      decoration: InputDecoration(
          hintText: widget.element.description ??
              AppLocalizations.of(context)!.writeAnswerHere,
          //+': '+widget.element.title.toString(),
          fillColor: createMaterialColor('#FFEDE30E')),
    );
  }
}

class RadioGroup extends StatefulWidget {
  final FormElement element;
  final List<dynamic> options;
  final int? selectedOption; // default / original selected option

  const RadioGroup(
      {super.key, required this.element, required this.options, this.selectedOption});

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}

class RadioGroupWidget extends State<RadioGroup> {
  // Default Radio Button Item
  int? selectedOptionValue;

  @override
  Widget build(BuildContext context) {
    if (selectedOptionValue == null&& widget.selectedOption!=null) {
      selectedOptionValue = widget.selectedOption;
    }
    //  print('building radio group; group value is '+this.selectedOptionValue.toString());

    return Column(children: [
      if (widget.element.description != null)
        Text(widget.element.description ?? ''),
      ...widget.options
          .map((data) => RadioListTile<dynamic>(
                title: Text("${data.value}"),
                groupValue: selectedOptionValue,
                value: data.id,
                onChanged: (val) {
                  setState(() {
                    //   print('selecting: '+data.value.toString()+' ('+data.id.toString()+')');
                    selectedOptionValue = data.id;

                    DisplayForm.of(context)!
                        .formData[widget.element.id ?? 0] = data.id;
                  });
                },
              ))
          ,
    ]);
  }
}
