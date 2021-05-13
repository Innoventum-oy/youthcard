import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/validators.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidateContact extends StatefulWidget {
  @override
  _ValidateContactState createState() => _ValidateContactState();
}

class _ValidateContactState extends State<ValidateContact> {
  final formKey = new GlobalKey<FormState>();

  String?  _confirmkey, _contactfieldid;

  ApiClient _apiClient = ApiClient();
  Widget getConfirmationKeyForm(auth) {
    final _contactController = TextEditingController();
    var getVerificationCode = () {
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
              print('contact method id set to '+response['contactmethodid'].toString());
              auth.setVerificationStatus(VerificationStatus.CodeReceived);
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
        print("form is invalid");
      }
    };

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.processing)
      ],
    );

    final contactField = TextFormField(
      controller: _contactController,
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
        auth.verificationStatus == VerificationStatus.Validating
            ? loading
            : longButtons(AppLocalizations.of(context)!.getCode,
            getVerificationCode),
        SizedBox(height: 5.0),

      ],
    );
  }


  Widget enterConfirmationKeyForm(auth) {
    final _confirmationController = TextEditingController();
    print('current _confirmkey value: '+_confirmkey.toString());
    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.processing)
      ],
    );

    final confirmationKeyField = TextFormField(
      autofocus: true,
      controller: _confirmationController,
      validator: (value) =>
      value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterConfirmationKey : null,
      onSaved: (value) => _confirmkey = value,
      decoration: buildInputDecoration(
          AppLocalizations.of(context)!.confirmationKey, Icons.vpn_key),
    );

    var sendVerificationCode = () {
      print('sending confirmation key');
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();
        print('checking confirmationkey - user: '+auth.userId+',  contactmethodid '+auth.contactMethodId.toString()+', key: '+_confirmkey.toString());

        final Future<Map<String, dynamic>> successfulMessage =
        _apiClient.sendConfirmationKey(userid: auth.userId,contact: auth.contactMethodId, code:_confirmkey!.toString());

        successfulMessage.then((response) {
          print('received response from sendConfirmationKey');
          if (response['status'] == 'success') {
            setState(() {
              auth.setSinglePass(response['singlepass']);
              auth.setVerificationStatus(VerificationStatus.Verified);
            });

          } else {
            print('sendConfirmationKey returned status '+response['status']);
            Flushbar(
              title: AppLocalizations.of(context)!.requestFailed,
              message: response['message'].toString(),
              duration: Duration(seconds: 3),
            ).show(context);
          }
        });
      } else {
        print("form is invalid");
      }
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        label(AppLocalizations.of(context)!.confirmationKey),
        SizedBox(height: 5.0),
        confirmationKeyField,

        SizedBox(height: 20.0),
        auth.verificationStatus == VerificationStatus.Validating
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

    var setPassword= () {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();
        final Future<Map<String, dynamic>> successfulMessage =
        _apiClient.changePassword(userid: auth.userId, password:_password, singlepass: auth.singlePass);

        successfulMessage.then((response) {
          if (response['status'] == 'success') {
            setState(() {
              print('password successfully changed for user');
              auth.setVerificationStatus(VerificationStatus.PasswordChanged);

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
        print("form is invalid");
      }
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        label(AppLocalizations.of(context)!.password),
        SizedBox(height: 5.0),
        passwordField,
        SizedBox(height: 20.0),
        auth.loggedInStatus == Status.Authenticating
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
      case VerificationStatus.Verified:
      // display button to return to code request form
        return TextButton(
            child: Text(AppLocalizations.of(context)!.requestNewCode,
                style: TextStyle(fontWeight: FontWeight.w300)),
            onPressed: () async {
              setState(() {
                auth.setVerificationStatus(VerificationStatus.CodeReceived);
              });
            });
        break;
      default:
        return TextButton(
            child: Text(AppLocalizations.of(context)!.previous,
                style: TextStyle(fontWeight: FontWeight.w300)),
            onPressed: () async {
              setState(() {
                auth.setVerificationStatus(VerificationStatus.CodeNotRequested);
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

    print('verification status:'+auth.verificationStatus.toString());

    switch(auth.verificationStatus)
    {
      case VerificationStatus.UserNotFound:
      case VerificationStatus.CodeNotRequested:
        return getConfirmationKeyForm(auth);

      case VerificationStatus.CodeReceived:
        return enterConfirmationKeyForm(auth);

      case VerificationStatus.Verified:
        return updatePasswordForm(auth);
      case VerificationStatus.PasswordChanged:
        return successForm();
      default:
        return Container();
    }
  }
}