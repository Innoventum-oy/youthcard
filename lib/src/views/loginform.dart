import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/util/brand.dart';
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

const bool _storeScreenshots = bool.fromEnvironment('STORE_SCREENSHOTS');

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
  String serverName = kReleaseMode ? AppUrl.productionServerName : '';
  String serverUrl = kReleaseMode ? AppUrl.productionServerHost : '';
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';
  bool openServerSelect = false;


  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) { if (!mounted) return; setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    }); });
    Settings().isServerSelected().then((val) { if (!mounted) return; setState(() {
      openServerSelect = !val;
    }); });

    Settings().getServer().then((val) { if (!mounted) return; setState(() {
      serverUrl = val;
    }); });
    Settings().getServerName().then((val) { if (!mounted) return; setState(() {

      serverName = val;
      if(AppUrl.anonymousApikeys.containsKey(serverName)) {
        Settings().setValue(
            'anonymousapikey', AppUrl.anonymousApikeys[serverName]);
        //print("Anonymous api key for " + serverName + " set to " +AppUrl.anonymousApikeys[serverName]!);
      }
    }); });
    if (kIsWeb && !kReleaseMode) {
      final host = Uri.base.host;
      final servers = AppUrl.servers;
      final foundEntry = servers.entries.firstWhere(
            (entry) => Uri.parse(entry.value).host == host,
        orElse: () => MapEntry('', ''),
      );

      if (foundEntry.key.isNotEmpty) {
        serverName = foundEntry.key;
        serverUrl = foundEntry.value;
        Settings().setValue('server', serverUrl);
        Settings().setValue('servername', serverName);
        // Optionally set anonymousapikey if needed
        if (AppUrl.anonymousApikeys.containsKey(serverName)) {
          Settings().setValue('anonymousapikey', AppUrl.anonymousApikeys[serverName]);
        }
        openServerSelect = false;
      } else {
        openServerSelect = true;
      }
    }

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

    final forgotLabel = Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
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
          if (!mounted) return;

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
          if (!mounted) return;
          Flushbar(
            title: AppLocalizations.of(context)!.loginFailed,
            message: AppLocalizations.of(context)!.networkError, // or e.toString()
            duration: Duration(seconds: 3),
          ).show(context);
        }
      } else {
      }
    }
    Widget titleText = AppUrl.serverImages.containsKey(serverName) ? Image.asset(AppUrl.serverImages[serverName] ?? 'images/brand/app-icon.png',height:100) : Text(serverName,
        style:TextStyle(
            fontSize: 24.0
        ));
    return SafeArea(
      child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).scaffoldBackgroundColor
              : (AppUrl.backgroundColors[serverName] ?? Theme.of(context).scaffoldBackgroundColor),
        appBar: AppBar(
          title: Row(children: [
            const BrandIcon(size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.youthcardLoginTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          elevation: 0.1,
        ),
        body: SingleChildScrollView(
          child:Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )],
              ),
          child: Form(
            key: formKey,
            child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: kReleaseMode || _storeScreenshots
                        ? titleText
                        : GestureDetector(
                            onTap: () => serverSelectDialog(context),
                            child: titleText,
                          ),
                  ),
                  SizedBox(height: 5.0),
                  if (!kReleaseMode && !_storeScreenshots)
                    TextButton(
                      child: Text(
                          '${AppLocalizations.of(context)!.environment}: $serverName',
                          style: TextStyle(fontWeight: FontWeight.w300)),
                      onPressed: () => serverSelectDialog(context),
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
        )
      ),
    );
  }
  void serverSelectDialog(BuildContext context){
    if (kReleaseMode || _storeScreenshots) return;
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
                themeData: SettingsThemeData(
                  settingsTileTextColor: Theme.of(context).colorScheme.onSurface,
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
            if(kDebugMode){
              print('Server selected: $serverUrl :: $serverTitle ');
            }
            Settings().setValue('server', serverUrl);
            Settings().setValue('servername', serverTitle);
            if (AppUrl.anonymousApikeys.containsKey(serverTitle)) {
              Settings().setValue(
                  'anonymousapikey', AppUrl.anonymousApikeys[serverTitle]);

            }
            else {
              Settings().clearValue('anonymousapikey');
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
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
        : Icon(null);
  }

  Widget getVersionInfo() {
    return Text('$appName v.$version($buildNumber)',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
  }
  Widget policyLink() {
    return TextButton(
        onPressed: () {
          //View policy page
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ContentPageView('privacy-policy')));
        },
        child: Text(AppLocalizations.of(context)!.privacyPolicy,
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.primary)));
  }
}
