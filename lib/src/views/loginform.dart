import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/validators.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:youth_card/src/views/webpagetextcontent.dart';

class Login extends StatefulWidget {
  final String viewTitle = 'login';
  final dynamic user;

  const Login({super.key, this.user});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  String? _contact, _password;
  String serverName = '';
  String serverUrl = '';
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';
  bool openServerSelect = false;
  LoginState() {

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) => setState(() {
          appName = packageInfo.appName;
          packageName = packageInfo.packageName;
          version = packageInfo.version;
          buildNumber = packageInfo.buildNumber;
        }));
    Settings().isServerSelected().then((val) => setState(() {
      openServerSelect = !val;
    }));

    Settings().getServer().then((val) =>  setState(() {
      serverUrl = val;
    }));
    Settings().getServerName().then((val) => setState(() {

          serverName = val;
          if(AppUrl.anonymousApikeys.containsKey(serverName)) {
            Settings().setValue(
                'anonymousapikey', AppUrl.anonymousApikeys[serverName]);
            //print("Anonymous api key for " + serverName + " set to " +AppUrl.anonymousApikeys[serverName]!);
          }
        }));
  }

  @override
  Widget build(BuildContext context) {

    if(openServerSelect==true)
    {
      openServerSelect = false;
      Future.delayed(Duration.zero, () =>serverSelectDialog(context));
    }
    //servername = AppLocalizations.of(context)!.loading;
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User? user = widget.user;
    String contact = '';
    if (user != null) {
      contact = user.phone != null
          ? user.phone!
          : user.email != null
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
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.forgotPassword,
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/reset-password');
          },
        ),
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.createAccount,
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            auth.setRegisteredStatus(Status.notRegistered);
            Navigator.pushReplacementNamed(context, '/register');
          },
        ),
      ],
    );

    final cancelButton = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel,
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () async {
            //auth.logout(user);
            auth.cancellogin();
          },
        ),
      ],
    );
    void bypassLogin(){
      Navigator.pushReplacementNamed(context, '/dashboard');

    }
    Future<void> doLogin() async {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();

        try {
          final response = await auth.login(_contact!, _password!, server: serverUrl);

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
        } catch (e) {
          Flushbar(
            title: AppLocalizations.of(context)!.loginFailed,
            message: AppLocalizations.of(context)!.networkError, // or e.toString()
            duration: Duration(seconds: 3),
          ).show(context);
        }
      } else {
      }
    }
    Widget titleText = AppUrl.serverImages.containsKey(serverName) ? Image.asset(AppUrl.serverImages[serverName] ?? 'images/icon.png',height:100) : Text(serverName,
        style:TextStyle(
            fontSize: 24.0
        ));
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppUrl.backgroundColors.containsKey(serverName) ? AppUrl.backgroundColors[serverName] : Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.youthcardLoginTitle),
          elevation: 0.1,
        ),
        body: SingleChildScrollView(
          child:Container(

              padding: EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child:GestureDetector(child: titleText, onTap: () {
          serverSelectDialog(context);
          },)
                  ),
                  SizedBox(height: 5.0),
                  TextButton(
                    child: Text(
                        '${AppLocalizations.of(context)!.environment}: $serverName',
                        style: TextStyle(fontWeight: FontWeight.w300)),
                    onPressed: () {
                      serverSelectDialog(context);
                    },
                  ),
                  SizedBox(height: 10.0),

                  label(AppLocalizations.of(context)!.phoneOrEmail),
                  SizedBox(height: 5.0),
                  contactField,
                  SizedBox(height: 10.0),
                  label(AppLocalizations.of(context)!.password),
                  SizedBox(height: 5.0),
                  passwordField,
                  SizedBox(height: 10.0),
                  auth.loggedInStatus == Status.authenticating
                      ? loading
                      : longButtons(
                          AppLocalizations.of(context)!.btnLogin, doLogin),
                  SizedBox(height: 10.0),
                  auth.loggedInStatus == Status.authenticating
                      ? Container()
                      : longButtons(
                      AppLocalizations.of(context)!.btnContinueWithoutLogin, bypassLogin),
                  SizedBox(height: 5.0),
                  forgotLabel,
                  SizedBox(height: 5.0),

                  auth.loggedInStatus == Status.authenticating
                      ? cancelButton
                      : Container(),
                  getVersionInfo(),
                  policyLink(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child:
            Image.asset('images/erasmusplus.png',
            height:40)
        )
      ),
    );
  }
  void serverSelectDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
          title: Text(
              AppLocalizations.of(context)!.environment),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(context).size.height *
                      0.9,
                  minHeight:
                  MediaQuery.of(context).size.height *
                      0.5,
                  maxWidth:
                  MediaQuery.of(context).size.width * 0.9,
                  minWidth:
                  MediaQuery.of(context).size.width *
                      0.9),
              child: SettingsTheme(
                themeData: const SettingsThemeData(
                  settingsTileTextColor: Colors.white,
                ),
                platform: detectPlatform(context),
                child:SettingsSection(
                  tiles: environmentOptions(context)),
            ),
          ),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          actions: <Widget>[
            ElevatedButton(
              child:
              Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ]),
    );

  }
  List<SettingsTile> environmentOptions(BuildContext context) {
    final Map<String,String> servers = AppUrl.servers;
    List<SettingsTile> tiles = [];
    servers.forEach((String serverTitle, String itemUrl) {
      tiles.add(SettingsTile(
        title: Text(serverTitle),

       leading: trailingWidget(serverTitle),
        onPressed: (BuildContext context) {

            serverName = serverTitle;
            serverUrl = itemUrl;
            Settings().setValue('server', serverUrl);
            Settings().setValue('servername', serverTitle);
            if (AppUrl.anonymousApikeys.containsKey(serverTitle)) {
              Settings().setValue(
                  'anonymousapikey', AppUrl.anonymousApikeys[serverTitle]);

            }
            else {
              Settings().setValue('anonymousapikey', null);
            }
            UserPreferences().removeUser();
            //  Provider.of<UserProvider>(context, listen: false).clearUser();
            //  Navigator.pushReplacementNamed(context, '/login');
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {

            });
        },
      ));
    });
    return tiles;
  }

  Widget trailingWidget(String currentname) {
    return (serverName == currentname)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }

  Widget getVersionInfo() {
    return Text('$appName v.$version($buildNumber)',
        style: TextStyle(color: Color(0xFF777777)));
  }
  Widget policyLink() {
    return TextButton(
        onPressed: () {
          //View policy page
          setState(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ContentPageView('privacy-policy')));
          });
        },
        child: Text(AppLocalizations.of(context)!.privacyPolicy,
            style: const TextStyle(
                fontWeight: FontWeight.w300, color: Color(0xFFffe8d7))));
  }
}
