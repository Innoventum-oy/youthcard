import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/objects/contactmethod.dart';

class ValidateContact extends StatefulWidget {
  final ContactMethod? contactmethod;

  ValidateContact({this.contactmethod});
  @override
  _ValidateContactState createState() => _ValidateContactState();
}

class _ValidateContactState extends State<ValidateContact> {
  bool contactsLoaded = false;
  final formKey = new GlobalKey<FormState>();
  ContactMethod contactmethod = new ContactMethod();
  List<ContactMethod> contactItems = [];
  ContactMethod? selectedMethod;

  String?  _confirmkey, _contact;
  String? errormessage;
  ApiClient _apiClient = ApiClient();

  @override
  void initState(){

    print('initState called for validatecontact');



      String address = this.contactmethod.address ??'null';
      print('setting _contact to '+address.toString());
      _contact = address;
      selectedMethod = this.contactmethod;
      print('Widget called with contactmethod '+address);

    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {


    // });
  super.initState();

  }
  @protected
  @mustCallSuper
  void didChangeDependencies() {
    //Provider.of<UserProvider>(context, listen: false).getContactMethods();
    if(widget.contactmethod!=null) contactItems.add(widget.contactmethod as ContactMethod);
    else if(!this.contactsLoaded) {
      print('Loading contactmethods from userprovider');
      Provider
          .of<UserProvider>(context)
          . getContactMethods();

      this.contactsLoaded = true;
    }
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = Provider.of<UserProvider>(context).user;
     contactItems = Provider
        .of<UserProvider>(context)
        .contacts;

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
        //something went wrong if we end up in the default case
        //todo: handle error status
        return Container();
    }
  }

  Widget getConfirmationKeyForm(auth,user) {

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



    Widget contactFieldItem(contactmethod) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Radio<ContactMethod>(
                onChanged:(ContactMethod? value){
                  setState(()
                  {
                    selectedMethod = value;
                    _contact = value!.address;
                  });
                },
                value:contactmethod,
                groupValue: selectedMethod ,
              ),
              title: Text(contactmethod.address),
              subtitle: Text(contactmethod.verified ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.notVerified),
            ),

          ]
      );
    }
    Widget contactField(user) {
      // User user = Provider.of<UserProvider>(context).user;
      if(contactItems.isNotEmpty)
        return ListView.builder(
            itemCount: contactItems.length,
            itemBuilder: (BuildContext context, int index) {

              return contactFieldItem(contactItems[index]);
            });
      else {
        //No contact methods found error
        return Container(

            child: Text(AppLocalizations.of(context)!.noContactMethodsFound),


        );

      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 15.0),
        Text(AppLocalizations.of(context)!.contactMethod, style: Theme.of(context).textTheme.headlineSmall,),
        SizedBox(height: 5.0),
         widget.contactmethod!=null ? Text(_contact ?? '') : Container(
           height:200,
           child:contactField(user),
        ),


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
       if(selectedMethod!=null) Text(selectedMethod!.address ?? '',style:TextStyle(fontSize:15,fontWeight:FontWeight.bold)),
        SizedBox(height: 15.0),
        label(AppLocalizations.of(context)!.confirmationKey),
        SizedBox(height: 5.0),
        confirmationKeyField,

        SizedBox(height: 20.0),
        auth.verificationStatus == VerificationStatus.Validating
            ? loading
            : longButtons(AppLocalizations.of(context)!.btnConfirm,
            sendVerificationCode),

      ],
    );
  }

  Widget successForm()
  {
    return Row(
        children:[
          Icon(Icons.check),
          Text(AppLocalizations.of(context)!.contactInformationValidated,
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize:20)),
      ]
    );

  }
  Widget bottomNavigation(auth) {
    List<Widget> elements = [];
    if(auth.loggedInStatus != Status.LoggedIn ) {
      elements.add(ElevatedButton(
        child: Text(AppLocalizations.of(context)!.login,
            style: TextStyle(fontWeight: FontWeight.w300)),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ));
    }
    else{
      elements.add(ElevatedButton(
        child: Text(AppLocalizations.of(context)!.btnDashboard,
            style: TextStyle(fontWeight: FontWeight.w300)),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
      ));
    }
    elements.add(returnButton(auth));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: elements,
    );
  }
  Widget returnButton(auth)
  {
    switch(auth.verificationStatus){
      case VerificationStatus.Verified:
      // display button to return to code request form
        return ElevatedButton(
            child: Text(AppLocalizations.of(context)!.requestNewCode,
                style: TextStyle(fontWeight: FontWeight.w300)),
            onPressed: () async {
              setState(() {
                auth.setVerificationStatus(VerificationStatus.CodeNotRequested);
              });
            });

      case VerificationStatus.Validating:
        case VerificationStatus.UserNotFound:
        case VerificationStatus.CodeReceived:
        return ElevatedButton(
            child: Text(AppLocalizations.of(context)!.previous,
                style: TextStyle(fontWeight: FontWeight.w300)),
            onPressed: () async {
              setState(() {
                auth.setVerificationStatus(VerificationStatus.CodeNotRequested);
              });
            });
      default:
        return Container();

    }//switch
  }



}