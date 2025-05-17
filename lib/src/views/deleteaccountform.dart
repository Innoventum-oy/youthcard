import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../objects/user.dart';
import '../providers/user_provider.dart';
import '../util/api_client.dart';
import '../util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import '../util/shared_preference.dart';

enum ActionStatus { idle, loading, success, fail }

class DeleteAccountAction extends StatefulWidget {
  const DeleteAccountAction({super.key});

  @override
  DeleteAccountActionState createState() => DeleteAccountActionState();
}

class DeleteAccountActionState extends State<DeleteAccountAction> {
  final formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  ActionStatus formStatus = ActionStatus.idle;
  User? user;

  void deleteAccount() {
    //final form = this.formKey.currentState;

    _apiClient.deleteUserAccount(user ?? User()).then((responsedata) async {
      var response = responsedata['data'] ?? responsedata;
      if (response != null) {
        if (response['status'] != null) {
          switch (response['status']) {
            case 'error':
              Flushbar(
                title: AppLocalizations.of(context)!.deletingAccountFailed,
                message: response['message'] != null
                    ? response['message'].toString()
                    : response['error'].toString(),
                duration: const Duration(seconds: 10),
              ).show(context);

              break;

            case 'success':
              // spell out something
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
              Provider.of<UserProvider>(context, listen: false).clearUser();
              await Flushbar(
                title: AppLocalizations.of(context)!.accountDeleted,
                message: response['message'] != null
                    ? response['message'].toString()
                    : response.toString(),
                duration: const Duration(seconds: 10),
              ).show(context);
              UserPreferences().removeUser();
          }
        } else {
          Flushbar(
            title: AppLocalizations.of(context)!.deletingAccountFailed,
            message: response['error'] != null
                ? response['error'].toString()
                : response.toString(),
            duration: const Duration(seconds: 10),
          ).show(context);
        }
      }
    });
  }

  List<Widget> formButtons() {
    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.loading)
      ],
    );

    List<Widget> formfields = [];

    formfields.add(const SizedBox(height: 10.0));
    formfields.add(label(AppLocalizations.of(context)!.deleteYourAccount));
    formfields.add(const SizedBox(height: 5.0));

    formfields.add(formStatus == ActionStatus.loading
        ? loading
        : longButtons(
            AppLocalizations.of(context)!.deleteAccount, confirmDeleteAccount));

    return formfields;
  }

  Widget deleteAccountBody(status) {
    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.loading)
      ],
    );

    switch (status) {
      case ActionStatus.idle:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Form(
            key: formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                AppLocalizations.of(context)!.accountDeletion,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ...formButtons(),
            ]),
          ),
        );

      case ActionStatus.loading:
        // display spinner
        return loading;

      case ActionStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                const Icon(Icons.check),
                Text(AppLocalizations.of(context)!.accountDeleted,
                    style: const TextStyle(fontSize: 20)),
              ]),
            ),

          ],
        );

      default:
        return Container();
    }
  }

  void confirmDeleteAccount() {
    String title = AppLocalizations.of(context)!.confirmDeletingAccount;
    String content = AppLocalizations.of(context)!.deletingAccountCannotUndone;
    List<Widget> dialogActions = [
      ElevatedButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop('dialog')),
      ElevatedButton(
          child: Text(AppLocalizations.of(context)!.deleteAccount),
          onPressed: () {
            deleteAccount();
            Navigator.of(context, rootNavigator: true).pop('dialog');
          }),
    ];
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: dialogActions,
            ));
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).user;
    return deleteAccountBody(formStatus);
  }
}
