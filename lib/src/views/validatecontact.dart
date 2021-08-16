import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/validators.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/objects/contactmethod.dart';

class ValidateContact extends StatefulWidget {
  @override
  _ValidateContactState createState() => _ValidateContactState();
}

class _ValidateContactState extends State<ValidateContact> {
  final formKey = new GlobalKey<FormState>();

  LoadingState _contactsloadingState = LoadingState.LOADING;
  List<ContactMethod> data =[];
  bool _isLoading = false;
  String?  _confirmkey, _contact;
  String? errormessage;
  ApiClient _apiClient = ApiClient();

  _loadContacts(user) async {
    _isLoading = true;

    print('Loading user contacts');
    try {

      var contacts =
      await  _apiClient.getContactMethods(user);
      setState(() {
        _contactsloadingState = LoadingState.DONE;
        if(contacts.isNotEmpty) {
          data.addAll(contacts);
          print(data.length.toString() + ' contacts loaded');
          _isLoading = false;
        }
        else
        {
          print('no contact methods were found for user '+user.id.toString());
        }
      });
    } catch (e,stack) {
      _isLoading = false;
      print('_loadContacts returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_contactsloadingState == LoadingState.LOADING) {
        setState(() => _contactsloadingState = LoadingState.ERROR);
      }
    }
  }

  Widget getConfirmationKeyForm(auth,user) {
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

  /*  final contactField = TextFormField(
      controller: _contactController,
      autofocus: false,
      validator: validateContact,
      onSaved: (value) => _contact = value,
      decoration: buildInputDecoration(
          AppLocalizations.of(context)!.email, Icons.email),
    );
*/
    Widget ContactFieldItem(contactmethod) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.event),
            title: Text(contactmethod.address),
            subtitle: Text(contactmethod.isVerified ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.notVerified),
          ),

        ]
    );
    }
    Widget contactField(user) {
      // User user = Provider.of<UserProvider>(context).user;

      switch (_contactsloadingState) {
        case LoadingState.DONE:

        //data loaded
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                if (!_isLoading) {

                  _loadContacts(user);
                }

                return ContactFieldItem(data[index]);
              });
        case LoadingState.ERROR:
        //data loading returned error state
          return Align(alignment:Alignment.center,
            child:ListTile(
              leading: Icon(Icons.error),
              title: Text('Sorry, there was an error loading the data: $errormessage'),
            ),
          );

        case LoadingState.LOADING:
        //data loading in progress
          return Align(alignment:Alignment.center,
            child:Center(
              child:ListTile(
                leading:CircularProgressIndicator(),
                title: Text(AppLocalizations.of(context)!.loading,textAlign: TextAlign.center),
              ),
            ),
          );
        default:
          return Container();
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        label(AppLocalizations.of(context)!.emailOrPhoneNumber),
        SizedBox(height: 5.0),
        contactField(user),
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

  Widget successForm()
  {
    return Text(AppLocalizations.of(context)!.contactInformationValidated,
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
  void initState(){
    print('initState called for validatecontact');
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {

      User user = Provider.of<UserProvider>(context,listen: false).user;

      _loadContacts(user);
    });


  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = Provider.of<UserProvider>(context,listen: false).user;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.validateContactTitle),
          elevation: 0.1,
        ),
        body: Container(
          padding: EdgeInsets.all(40.0),
          child: Column(
              children:
              [Form(
                  key: formKey,
                  child: contactValidationFormBody(auth,user)
              ),
                bottomNavigation(auth),
              ]
          ),
        ),
      ),
    );
  }

  Widget contactValidationFormBody(auth,user)
  {

    print('verification status:'+auth.verificationStatus.toString());

    switch(auth.verificationStatus)
    {
      case VerificationStatus.UserNotFound:
      case VerificationStatus.CodeNotRequested:
        return getConfirmationKeyForm(auth,user);

      case VerificationStatus.CodeReceived:
        return enterConfirmationKeyForm(auth);

      case VerificationStatus.Verified:
        return successForm();
      default:
        return Container();
    }
  }
}