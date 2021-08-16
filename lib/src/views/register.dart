import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/validators.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/shared_preference.dart';


enum ContactMethod{
  Phone,
  Email
}
class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  String? _firstname, _lastname, _email,_phone, _password, _confirmPassword;

  ContactMethod selectedContactMethod = ContactMethod.Phone;


 List<Widget> formButtons(auth)
  {
    var doRegister = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        _apiClient.register(firstname:_firstname.toString(), lastname: _lastname.toString(),email:_email.toString(),phone: _phone.toString(), password:_password.toString(), passwordConfirmation:_confirmPassword.toString())!.then((responsedata) {
          var response = responsedata['data'];
          if(response!=null) if( response['status']!=null) {

            switch(response['status']) {
              case 'error':
                Flushbar(
                  title: AppLocalizations.of(context)!.registrationFailed,
                  message: response['message'] !=null ? response['message'].toString() : response.toString(),
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
                    print('setting registeredStatus to Registered');
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

    final firstnameField = TextFormField(
      autofocus: false,
     // validator: validateEmail,
      onSaved: (value) => _firstname = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.firstName,Icons.person ),
    );
    final lastnameField = TextFormField(
      autofocus: false,
      // validator: validateEmail,
      onSaved: (value) => _lastname = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.lastName,Icons.person ),
    );
    final emailField = TextFormField(
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _email = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.email, Icons.email),
    );
    final phoneField = TextFormField(
      autofocus: false,
     // validator: validateEmail,
      onSaved: (value) => _phone = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.phone, Icons.phone_iphone),
    );
    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterPassword : null,
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.confirmPassword, Icons.lock),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      validator: (value) => value!.isEmpty ?AppLocalizations.of(context)!.passwordIsRequired : null,
      onSaved: (value) => _confirmPassword = value,
      obscureText: true,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.confirmPassword, Icons.lock),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.pleaseWaitRegistering)
      ],
    );

    List <Widget> formfields = [
      label(AppLocalizations.of(context)!.firstName),
      SizedBox(height: 5.0),
      firstnameField,
      SizedBox(height: 15.0),
      label(AppLocalizations.of(context)!.lastName),
      SizedBox(height: 5.0),
      lastnameField,
      SizedBox(height: 15.0),
      label(AppLocalizations.of(context)!.password),
      SizedBox(height: 10.0),
      passwordField,
      SizedBox(height: 15.0),
      label(AppLocalizations.of(context)!.confirmPassword),
      SizedBox(height: 10.0),
      confirmPasswordField,
      SizedBox(height: 15.0),
  ];
    switch(selectedContactMethod) {
      case ContactMethod.Email:
        //add email field + change to phone field button
      formfields.add(label(AppLocalizations.of(context)!.email));
      formfields.add(emailField);
      formfields.add(TextButton(
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
        formfields.add(label(AppLocalizations.of(context)!.phone));
        formfields.add(phoneField);
        formfields.add(TextButton(
        onPressed: () {
          // Change to email field
          setState((){
            selectedContactMethod = ContactMethod.Email;
         });
        },
        child: Text(AppLocalizations.of(context)!.btnUseEmail,style: TextStyle(fontWeight: FontWeight.w300)))
        );

    }

   formfields.add( SizedBox(height: 20.0));
    formfields.add( auth.registeredStatus == Status.Authenticating
    ? loading
        : longButtons(AppLocalizations.of(context)!.createAccount, doRegister));
    formfields.add(TextButton(
      onPressed: () {
      // Navigate back to the first screen by popping the current route
      // off the stack.
      Navigator.of(context, rootNavigator: true).pop(context);

      },
      child: Text(AppLocalizations.of(context)!.btnReturn,style: TextStyle(fontWeight: FontWeight.w300)))
    );

    return formfields;
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
        break;

      case Status.Registering:
        // display spinner
      return loading;
        break;

      case Status.Registered:
        print('Status.Registered switch handler');
        //TODO display success message + option to continue to dashboard or to confirm contact method
        return  Column(
              children: <Widget>[
                SizedBox(height: 15.0),
                TextButton(
                    onPressed: () {
                      // continue to validate contact information
                      switch(selectedContactMethod) {
                        case ContactMethod.Email:
                          break;
                        default:
                      }
                      Navigator.pushReplacementNamed(context, '/validateContact');
                    },
                    child: Text(AppLocalizations.of(context)!.btnValidateContact,style: TextStyle(fontWeight: FontWeight.w300))),
                SizedBox(height: 15.0),
                TextButton(
                    onPressed: () {
                      // continue to dashboard
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: Text(AppLocalizations.of(context)!.btnValidateContactLater,style: TextStyle(fontWeight: FontWeight.w300)))
              ],
        );



      default:
        return Container();
        break;
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