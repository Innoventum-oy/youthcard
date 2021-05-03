import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/validators.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();

  String? _username, _password, _confirmPassword;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final usernameField = TextFormField(
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _username = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.confirmPassword, Icons.email),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterPassword : null,
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration(AppLocalizations.of(context)!.confirmPassword, Icons.lock),
    );

    final confirmPassword = TextFormField(
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

    var doRegister = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        auth.register(_username.toString(), _password.toString(), _confirmPassword.toString())!.then((response) {

          if(response!=null) if( response['status']!=null) {

            User? user = response != null ? response['data'] as User : null;
            Provider.of<UserProvider>(context, listen: false).setUser(user!);
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Flushbar(
              title: AppLocalizations.of(context)!.registrationFailed,
              message: response.toString(),
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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createAccount),
          elevation: 0.1,
        ),
        body: Container(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.0),
                label(AppLocalizations.of(context)!.email),
                SizedBox(height: 5.0),
                usernameField,
                SizedBox(height: 15.0),
                label(AppLocalizations.of(context)!.password),
                SizedBox(height: 10.0),
                passwordField,
                SizedBox(height: 15.0),
                label(AppLocalizations.of(context)!.confirmPassword),
                SizedBox(height: 10.0),
                confirmPassword,
                SizedBox(height: 20.0),
                auth.loggedInStatus == Status.Authenticating
                    ? loading
                    : longButtons(AppLocalizations.of(context)!.createAccount, doRegister),TextButton(

            onPressed: () {
              // Navigate back to the first screen by popping the current route
              // off the stack.
              Navigator.of(context, rootNavigator: true).pop(context);

            },
            child: Text(AppLocalizations.of(context)!.btnReturn,style: TextStyle(fontWeight: FontWeight.w300)))

              ],
            ),
          ),
        ),
      ),
    );
  }
}