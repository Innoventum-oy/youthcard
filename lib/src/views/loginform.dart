import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/validators.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:youth_card/src/views/settings/environment.dart';

class Login extends StatefulWidget {
  dynamic? user;

  Login({this.user});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = new GlobalKey<FormState>();

  String? _contact, _password;
  String servername = '';

  _LoginState() {
    Settings().getServerName().then((val) => setState(() {
          servername = val;
        }));
  }

  @override
  Widget build(BuildContext context) {
    //servername = AppLocalizations.of(context)!.loading;
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User? user = widget.user;
    String contact = '';
    if (user != null) {
      contact = user.phone!=null
          ? user.phone!
          : user.email!=null
              ? user.email!
              : '';
    }
    final contactField = TextFormField(
        autofocus: false,
        validator: validateContact,
        onSaved: (value) => _contact = value,
        decoration: buildInputDecoration(
            AppLocalizations.of(context)!.email, Icons.email),
        initialValue: contact);

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty
          ? AppLocalizations.of(context)!.pleaseEnterPassword
          : null,
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration(
          AppLocalizations.of(context)!.confirmPassword, Icons.lock),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.authenticating)
      ],
    );

    final forgotLabel = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.forgotPassword,
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/reset-password');
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.createAccount,
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
      ],
    );
    /* final cancelButton = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget> [
        TextButton(

          child: Text(AppLocalizations.of(context)!.cancel,
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () async {

            //auth.logout(user);
            auth.cancellogin();
          },
        ),
      ],
    );*/

    var doLogin = () {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();

        final Future<Map<String, dynamic>> successfulMessage =
            auth.login(_contact!, _password!);

        successfulMessage.then((response) {
          if (response['status']) {
            User user = response['user'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Provider.of<UserProvider>(context, listen: false).clearUser();
            Flushbar(
              title: AppLocalizations.of(context)!.loginFailed,
              message: response['message'].toString(),
              duration: Duration(seconds: 3),
            ).show(context);
          }
        });
      } else {
        print("form is invalid");
      }
    };

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.youthcardLoginTitle),
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
                label(AppLocalizations.of(context)!.phoneOrEmail),
                SizedBox(height: 5.0),
                contactField,
                SizedBox(height: 20.0),
                label(AppLocalizations.of(context)!.password),
                SizedBox(height: 5.0),
                passwordField,
                SizedBox(height: 20.0),
                auth.loggedInStatus == Status.Authenticating
                    ? loading
                    : longButtons(
                        AppLocalizations.of(context)!.btnLogin, doLogin),
                SizedBox(height: 5.0),
                forgotLabel,
                SizedBox(height: 5.0),
                TextButton(
                  child: Text(
                      AppLocalizations.of(context)!.environment +
                          ': ' +
                          servername,
                      style: TextStyle(fontWeight: FontWeight.w300)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                          title: new Text(
                              AppLocalizations.of(context)!.environment),
                          content: EnvironmentScreen(wrap: false),
                          insetPadding: EdgeInsets.symmetric(horizontal: 50),
                          actions: <Widget>[
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ]),
                    );
                  },
                ),

                /* SizedBox(height: 15.0),
                cancelButton,*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
