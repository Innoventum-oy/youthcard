import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/api_client.dart';

import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:youth_card/src/views/webpagetextcontent.dart';


enum ContactMethod{
  Phone,
  Email
}
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();

  static RegisterState? of(BuildContext context) =>
      context.findAncestorStateOfType<RegisterState>();
}

class RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  String? _firstname,
      _lastname,
      _email,
      _phone,
      _password,
      _confirmPassword,
      _guardianname,
      _guardianphone,
      _registrationCode;
  bool isOver18 = true;
  bool _savingInfoAccepted = false;

  ContactMethod selectedContactMethod = ContactMethod.Phone;
  Map<String,TextEditingController> controllers = {
  'lastname' : new TextEditingController(),
  'firstname': new TextEditingController(),
  'email' : new TextEditingController(),
  'phone' : new TextEditingController(),
  'code': TextEditingController(), ''
   'password': TextEditingController(),
  'guadianname': TextEditingController(),
  'guardianphone': TextEditingController()
  };

 List<Widget> formButtons(auth)
  {
    var doRegister = () {
      final form = formKey.currentState;
      if(_savingInfoAccepted!=true){
        Flushbar(
          title: AppLocalizations.of(context)!.registrationFailed,
          message: AppLocalizations.of(context)!.youHaveToAgreeToSavingUserInformation,
          duration: const Duration(seconds: 10),
        ).show(context);

      }
      else if (form!.validate()) {
        form.save();
        _apiClient.register(
            firstname:_firstname.toString(),
            lastname: _lastname.toString(),
            email:_email.toString(),
            phone: _phone.toString(),
            password:_password.toString(),
            passwordConfirmation:_confirmPassword.toString(),
          registrationCode: _registrationCode.toString(),
          guardianName: _guardianname.toString(),
          guardianPhone: _guardianphone.toString(),
        )!.then((responsedata) {
          var response = responsedata['data'] ?? responsedata;
          if(response!=null) if( response['status']!=null) {
            switch(response['status']) {
              case 'error':
                Flushbar(
                  title: AppLocalizations.of(context)!.registrationFailed,
                  message: response['message'] !=null ? response['message'].toString() : response['error'].toString(),
                  duration: Duration(seconds: 10),
                ).show(context);
                break;

              case 'success':
                if (response['user'] != null) {
                  var userData = response['user'];
                  print('saving users to UserPreferences');
                  User authUser = User.fromJson(userData);

                  UserPreferences().saveUser(authUser);

                  auth.setLoggedInStatus(Status.LoggedIn);
                  auth.setContactMethodId(response['contactmethodid']);
                  Provider.of<UserProvider>(context, listen: false).setUser(
                      authUser);
                  setState(() {
                    auth.setRegisteredStatus(Status.Registered);
                  });
                }
            }
          } else {
            Flushbar(
              title: AppLocalizations.of(context)!.registrationFailed,
              message: response['error'] !=null ? response['error'].toString() : response.toString(),
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
    String? validateName(String? value) {
      String? _msg;

      if (value!.isEmpty) {
        _msg = AppLocalizations.of(context)!.pleaseProvideYourName;
      }
      return _msg;
    }
    String? validatePhone(String? value)
    {

      String? _msg;
      if(value!.isEmpty) return AppLocalizations.of(context)!.pleaseEnterPhonenumber;

      //test for phone number pattern
      String pattern = r'(^(?:[+0])?[0-9]{8,12}$)';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        _msg = AppLocalizations.of(context)!.pleaseProvideValidPhonenumber;
      }
      return _msg;
    }

    String? validateEmail(String? value) {
      String? _msg;
      RegExp regex = new RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
      if (value!.isEmpty) {
        _msg = AppLocalizations.of(context)!.pleaseProvideValidEmail;
      } else if (!regex.hasMatch(value)) {
        _msg = AppLocalizations.of(context)!.pleaseProvideValidEmail;
      }
      return _msg;
    }
    String? validateGuardianPhone(String? value) {
      String? msg;
      if (isOver18) return null;
      if (value!.isEmpty) {
        return AppLocalizations.of(context)!.pleaseEnterPhonenumber;
      }
      return msg;
    }
      final guardianNameField = TextFormField(
        autofocus: false,
        controller: controllers['guardianname'],
        validator: (value) => value!.isEmpty && !isOver18
            ? AppLocalizations.of(context)!.valueIsRequired
            : null,
        onSaved: (value) => _guardianname = value,
        decoration: buildInputDecoration(
            AppLocalizations.of(context)!.guardianName, Icons.person),
      );

      final codeField = TextFormField(
        autofocus: false,
        controller: controllers['code'],
       // validator: validateCode,
        onSaved: (value) => _registrationCode = value,
        decoration: buildInputDecoration(
            AppLocalizations.of(context)!.groupCode, Icons.code),
      );

    final firstnameField = TextFormField(
      autofocus: false,
      controller : controllers['firstname'],
      validator: validateName,
      onSaved: (value) => _firstname = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.firstName,Icons.person ),
    );

    final lastnameField = TextFormField(
      autofocus: false,
       controller: controllers['lastname'],
       validator: validateName,
      onSaved: (value) => _lastname = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.lastName,Icons.person ),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: controllers['email'],
      validator: validateEmail,
      onSaved: (value) => _email = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.email, Icons.email),
    );

    final phoneField = TextFormField(
      autofocus: false,
      controller: controllers['phone'],
      validator: validatePhone,
      onChanged: (value) => _phone = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.phone, Icons.phone_iphone),
    );
    final guardianPhoneField = TextFormField(
      autofocus: false,
      controller: controllers['guardianphone'],
      validator: validateGuardianPhone,
      onChanged: (value) => _guardianphone = value,
      decoration: buildInputDecoration(
          AppLocalizations.of(context)!.guardianPhone, Icons.phone_iphone),
    );
    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterPassword : null,
      onChanged: (value) => _password = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.confirmPassword, Icons.lock),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      validator: (value) { if(value != _password) {
        print(value.toString()+' != '+_password.toString());
        return AppLocalizations.of(context)!.passwordsDontMatch;
      }
      if(value!.isEmpty)  return AppLocalizations.of(context)!.passwordIsRequired;
      return null;
      },
      onSaved: (value) => _confirmPassword = value,
      obscureText: true,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.confirmPassword, Icons.lock),
    );
    final acceptSavingInfoField = CheckboxListTile(
        value:  _savingInfoAccepted,
        onChanged: (val){

          setState(() {
            _savingInfoAccepted = val ?? false;
          });

        },title: Text(AppLocalizations.of(context)!.agreeOnSavingInfo),
        subtitle: TextButton(
            onPressed: () {
              //View account info page
              setState(() {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ContentPageView('privacy-policy')));
              });
            },
            child:Row(children:[Icon(Icons.info),Text(AppLocalizations.of(context)!.moreInformation,          style: const TextStyle(
                fontWeight: FontWeight.w300, color: Color(0xFFffe8d7)))])
        )
    );
    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.pleaseWaitRegistering)
      ],
    );

    List <Widget> formFields = [
      label(AppLocalizations.of(context)!.firstName),
      SizedBox(height: 5.0),
      firstnameField,
      SizedBox(height: 10.0),
      label(AppLocalizations.of(context)!.lastName),
      SizedBox(height: 5.0),
      lastnameField,
      SizedBox(height: 10.0),
      label(AppLocalizations.of(context)!.ageOver18),
      AgeSelectDisplay(options: [
        {'value': AppLocalizations.of(context)!.valueYes, 'id': 1},
        {'value': AppLocalizations.of(context)!.valueNo, 'id': 0}
      ]),
    ];
    if (!isOver18) {
      formFields.addAll([
        headingLabel(AppLocalizations.of(context)!.guardianInfo),
        Padding(

          padding: EdgeInsets.only(left: 15),
        child:
        Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,children:[  const SizedBox(height: 10.0),

  const SizedBox(height: 5.0),
  label(AppLocalizations.of(context)!.guardianName),
  guardianNameField,
  const SizedBox(height: 10.0),
  label(AppLocalizations.of(context)!.guardianPhone),
  guardianPhoneField,
  const SizedBox(height: 25.0),]
        ),
        ),

      ]);
    }
    formFields.addAll([
      label(AppLocalizations.of(context)!.password),
      SizedBox(height: 5.0),
      passwordField,
      SizedBox(height: 10.0),
      label(AppLocalizations.of(context)!.confirmPassword),
      SizedBox(height: 5.0),
      confirmPasswordField,
      SizedBox(height: 15.0),
  ]);
    switch(selectedContactMethod) {
      case ContactMethod.Email:
        //add email field + change to phone field button
      //clear possible phone field value
      _phone='';
      controllers['phone']!.clear();
      formFields.add(label(AppLocalizations.of(context)!.email));
      formFields.add(emailField);
      formFields.add(TextButton(
          onPressed: () {
            // Change to phone field
            setState((){
              selectedContactMethod = ContactMethod.Phone;
            });
          },
          child: Text(AppLocalizations.of(context)!.btnUsePhone,style: TextStyle(fontWeight: FontWeight.w300)))
      );
        break;

      default:
        // add phone field + change to email button

        //clear possible email field value
        _email = '';
        controllers['email']!.clear();
        formFields.add(label(AppLocalizations.of(context)!.phone));
        formFields.add(phoneField);
        formFields.add(TextButton(
        onPressed: () {
          // Change to email field
          setState((){
            selectedContactMethod = ContactMethod.Email;
         });
        },
        child: Text(AppLocalizations.of(context)!.btnUseEmail,style: TextStyle(fontWeight: FontWeight.w300)))
        );

    }

   formFields.addAll([ SizedBox(height: 20.0),
    auth.registeredStatus == Status.Authenticating
    ? loading
        : longButtons(AppLocalizations.of(context)!.createAccount, doRegister),
     const SizedBox(height: 5.0),
     acceptSavingInfoField,
    ElevatedButton(
      onPressed: () {
      // Navigate back to the first screen by popping the current route
      // off the stack.
        Navigator.pushReplacementNamed(context, '/login');

      },
      child: Text(AppLocalizations.of(context)!.btnReturn,style: TextStyle(fontWeight: FontWeight.w300)))
    ]);

    return formFields;
  }

  Widget registerViewBody(auth)
  {
    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.pleaseWaitRegistering)
      ],
    );

    switch(auth.registeredStatus){

      case Status.NotRegistered:
       return Container(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                formButtons(auth),

            ),
          ),
        );

      case Status.Registering:
        // display spinner
      return loading;


      case Status.Registered:
        print('Status.Registered switch handler');

        return  Padding(
          padding:EdgeInsets.all(20),
            child:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
            children:[
              Icon(Icons.check),
              Text(AppLocalizations.of(context)!.accountCreated,
              style:TextStyle(fontSize:20)),
            ]),
            SizedBox(height: 15.0),
            ElevatedButton(
                onPressed: () {
                  // Navigate to validatecontact
                  Navigator.pushReplacementNamed(context, '/validatecontact');
                },
                child: Text(AppLocalizations.of(context)!.btnValidateContact,style: TextStyle(fontWeight: FontWeight.w300))),
            SizedBox(height: 15.0),
            ElevatedButton(
                onPressed: () {
                  // Navigate to dashboard
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: Text(AppLocalizations.of(context)!.btnValidateContactLater,style: TextStyle(fontWeight: FontWeight.w300)))
          ],
        ),
        );

      default:
        return Container();

    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createAccount),
          elevation: 0.1,
        ),
        body: SingleChildScrollView(
            child:registerViewBody(auth)
        )
      ),
    );
  }
}


class AgeSelectDisplay extends StatefulWidget {
  final List<dynamic> options;
  final int? selectedOption; // default / original selected option

  const AgeSelectDisplay(
      {super.key, required this.options, this.selectedOption});

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}

class RadioGroupWidget extends State<AgeSelectDisplay> {
  // Default Radio Button Item
  int? selectedOptionValue;

  @override
  Widget build(BuildContext context) {
    //  print('building radio group; group value is '+this.selectedOptionValue.toString());

    return Column(children: [
      ...widget.options
          .map((data) =>
          RadioListTile<dynamic>(
            title: Text("${data['value']}"),
            groupValue: selectedOptionValue,
            value: data['id'],
            onChanged: (val) {
              setState(() {
                //   print('selecting: '+data.value.toString()+' ('+data.id.toString()+')');
                selectedOptionValue = data['id'];
                Register.of(context)!.setState(() {
                  Register.of(context)!.isOver18 =
                  data['id'] == 1 ? true : false;
                });
              });
            },
          ))
          .toList(),
    ]);
  }
}