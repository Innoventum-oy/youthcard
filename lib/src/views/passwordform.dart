import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/validators.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  final formKey = GlobalKey<FormState>();

  String? _contact, _confirmkey,_password;

  final ApiClient _apiClient = ApiClient();
  Widget getConfirmationKeyForm(auth) {
    final contactController = TextEditingController();
    void getVerificationCode() {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();

        final Future<Map<String, dynamic>> successfulMessage =
        _apiClient.getConfirmationKey(_contact!);

        successfulMessage.then((response) {
          if (response['status'] == 'success') {
            setState(() {
              auth.setContactMethodId(response['contactmethodid']);
             if(response['userid']!=null) auth.setUserId(response['userid']);
              auth.setVerificationStatus(VerificationStatus.codeReceived);
            });

          } else {
            Flushbar(
              title: AppLocalizations.of(context)!.requestFailed,
              message: response['message'].toString(),
              duration: Duration(seconds: 3),
            ).show(context);
          }
        });
      } else {
      }
    }

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.processing)
      ],
    );

    final contactField = TextFormField(
      controller: contactController,
      autofocus: false,
      validator: validateContact,
      onSaved: (value) => _contact = value,
      decoration: buildInputDecoration(
          AppLocalizations.of(context)!.email, Icons.email),
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        label(AppLocalizations.of(context)!.emailOrPhoneNumber),
        SizedBox(height: 5.0),
        contactField,
        SizedBox(height: 20.0),
        auth.verificationStatus == VerificationStatus.validating
            ? loading
            : longButtons(AppLocalizations.of(context)!.getCode,
            getVerificationCode),
        SizedBox(height: 5.0),

      ],
    );
  }


  Widget enterConfirmationKeyForm(auth) {
    final confirmationController = TextEditingController();
    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.processing)
      ],
    );

    final confirmationKeyField = TextFormField(
      autofocus: true,
      controller: confirmationController,
      validator: (value) =>
      value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterConfirmationKey : null,
      onSaved: (value) => _confirmkey = value,
      decoration: buildInputDecoration(
          AppLocalizations.of(context)!.confirmationKey, Icons.vpn_key),
    );

    void sendVerificationCode() {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();

        final Future<Map<String, dynamic>> successfulMessage =
        _apiClient.sendConfirmationKey(userid: auth.userId,contact: auth.contactMethodId, code:_confirmkey!.toString());

        successfulMessage.then((response) {
          if (response['status'] == 'success') {
            setState(() {
              auth.setSinglePass(response['singlepass']);
              auth.setVerificationStatus(VerificationStatus.verified);
            });

                } else {
                Flushbar(
                title: AppLocalizations.of(context)!.requestFailed,
                message: response['message'].toString(),
                duration: Duration(seconds: 3),
                ).show(context);
                }
            });
      } else {
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        label(AppLocalizations.of(context)!.confirmationKey),
        SizedBox(height: 5.0),
        confirmationKeyField,

        SizedBox(height: 20.0),
        auth.verificationStatus == VerificationStatus.validating
            ? loading
            : longButtons(AppLocalizations.of(context)!.btnSend,
            sendVerificationCode),

      ],
    );
  }

  Widget updatePasswordForm(auth) {

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.processing)
      ],
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) =>
      value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterPassword : null,
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration(
          AppLocalizations.of(context)!.confirmPassword, Icons.lock),
    );

    void setPassword() {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();
        final Future<Map<String, dynamic>> successfulMessage =
        _apiClient.changePassword(userid: auth.userId, password:_password, singlepass: auth.singlePass);

        successfulMessage.then((response) {
          if (response['status'] == 'success') {
            setState(() {
              auth.setVerificationStatus(VerificationStatus.passwordChanged);

            });

          } else {
            Flushbar(
              title: AppLocalizations.of(context)!.requestFailed,
              message: response['message'].toString(),
              duration: Duration(seconds: 3),
            ).show(context);
          }
        });
      } else {
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        label(AppLocalizations.of(context)!.password),
        SizedBox(height: 5.0),
        passwordField,
        SizedBox(height: 20.0),
        auth.loggedInStatus == Status.authenticating
            ? loading
            : longButtons(AppLocalizations.of(context)!.btnSetNewPassword,
            setPassword),
        SizedBox(height: 5.0),

      ],
    );
  }
  Widget successForm()
  {
    return Text(AppLocalizations.of(context)!.passwordChanged,
        style: TextStyle(fontWeight: FontWeight.w300));

  }
 Widget bottomNavigation(auth) {
   return Row(
     mainAxisAlignment: MainAxisAlignment.spaceBetween,
     children: <Widget>[
       TextButton(
         child: Text(AppLocalizations.of(context)!.login,
             style: TextStyle(fontWeight: FontWeight.w300)),
         onPressed: () {
           Navigator.pushReplacementNamed(context, '/login');
         },
       ),
       TextButton(

         child: Text(AppLocalizations.of(context)!.signUp,
             style: TextStyle(fontWeight: FontWeight.w300)),
         onPressed: () {
           Navigator.pushNamed(context, '/register');
         },
       ),
       returnButton(auth),
     ],
   );
 }
  Widget returnButton(auth)
  {
     switch(auth.verificationStatus){
        case VerificationStatus.verified:
      // display button to return to code request form
          return TextButton(
              child: Text(AppLocalizations.of(context)!.requestNewCode,
                  style: TextStyle(fontWeight: FontWeight.w300)),
              onPressed: () async {
                setState(() {
                  auth.setVerificationStatus(VerificationStatus.codeReceived);
                });
              });

      default:
       return TextButton(
        child: Text(AppLocalizations.of(context)!.previous,
        style: TextStyle(fontWeight: FontWeight.w300)),
        onPressed: () async {
          setState(() {
            auth.setVerificationStatus(VerificationStatus.codeNotRequested);
          });
      });

     }//switch
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.requestNewPasswordTitle),
          elevation: 0.1,
        ),
        body: Container(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children:
            [Form(
              key: formKey,
              child: passwordRetrievalFormBody(auth)
              ),
            bottomNavigation(auth),
            ]
        ),
      ),
    ),
    );
  }

  Widget passwordRetrievalFormBody(auth)
  {


    switch(auth.verificationStatus)
    {
      case VerificationStatus.userNotFound:
      case VerificationStatus.codeNotRequested:
        return getConfirmationKeyForm(auth);

      case VerificationStatus.codeReceived:
        return enterConfirmationKeyForm(auth);

      case VerificationStatus.verified:
      return updatePasswordForm(auth);
      case VerificationStatus.passwordChanged:
        return successForm();
      default:
        return Container();
    }
  }
}