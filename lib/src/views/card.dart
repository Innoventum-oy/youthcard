import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/userbenefit.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/utils.dart';
/*
* User card
*/

class MyCard extends StatefulWidget {
  final objectmodel.UserBenefitProvider userBenefitProvider =
      objectmodel.UserBenefitProvider();

  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  List<UserBenefit> benefits = [];
  LoadingState _benefitsLoadingState = LoadingState.LOADING;
  //bool _isLoading = false;
  String? errormessage;

  _loadBenefits(user) async {
    print('loadbenefits called');

    final Map<String, String> params = {
      'action': 'loaduserbenefits',
      'userid': user.id.toString(),
      'api_key': user.token,

    };

    try {
      var result = await widget.userBenefitProvider.loadItems(params);
      setState(() {
        _benefitsLoadingState = LoadingState.DONE;
        print(result);

        benefits.addAll(result);
        print(result.length.toString() + ' benefits currently loaded!');
        //_isLoading = false;
      });
    } catch (e, stack) {
      //_isLoading = false;
      print('loadItems returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_benefitsLoadingState == LoadingState.LOADING) {
        setState(() => _benefitsLoadingState = LoadingState.ERROR);
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;

      _loadBenefits(user);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;

    return OrientationBuilder(builder: (context, orientation) {
      //  print(orientation);
      // Choose between portraitlayout and landscapelayout based on device orientation
      return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myCard),
            elevation: 0.1,
          ),
          body: orientation == Orientation.portrait
              ? _portraitLayout(user)
              : _landscapeLayout(user));
    });
  }

  Widget _portraitLayout(user) {
    return Column(
      children: [
        SizedBox(height: 20),
        Center(
            child: user.qrcode != null && user.qrcode!.isNotEmpty
                ? Image.network(user.qrcode!, height: 200)
                : Container()),
        SizedBox(height: 20),
        Center(child: _loggedInView(context, user)),
        SizedBox(height: 20),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.btnReturn)),
        _getBenefitsSection(user),
      ],
    );
  }

  Widget _landscapeLayout(user) {
    return Padding(
        padding: EdgeInsets.all(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user.qrcode != null && user.qrcode!.isNotEmpty
                ? Image.network(user.qrcode!, height: 200)
                : Container(),
            _loggedInView(context, user),
            _getBenefitsSection(user),
          ],
        ));
  }

  Widget _loggedInView(BuildContext context, user) {
    List<String> nameparts = [];
    nameparts.add(user.firstname ?? 'John');
    nameparts.add(user.lastname ?? 'Doe');

    String username = nameparts.join(' ');
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _drawAvatar(
              user.image != null && user.image!.isNotEmpty
                  ? NetworkImage(user.image)
                  : Image.asset('images/profile.png').image,
              user),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _drawLabel(context, username),
            Text(user.email ?? '-'),
          ])
        ],
      ),
    );
  }

  Padding _drawLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }

  Padding _drawAvatar(ImageProvider imageProvider, User user) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: CircleAvatar(
        backgroundImage: imageProvider,
        backgroundColor: Colors.white10,
        radius: 48.0,
        child: getInitials(user),
      ),
    );
  }

  Widget _getBenefitsSection(user) {
    switch (_benefitsLoadingState) {
      case LoadingState.DONE:
        //data loaded

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                ),
                itemCount: benefits.length,
                itemBuilder: (BuildContext context, int index) {
                  return _userBenefitListItem(benefits[index]);
                }),
          ),
        );
      case LoadingState.ERROR:
        //data loading returned error state
        return Container(
          alignment: Alignment.center,
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
                'Sorry, there was an error loading the data: $errormessage'),
          ),
        );

      case LoadingState.LOADING:
        //data loading in progress
        return Container(
          alignment: Alignment.center,
          child: Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(AppLocalizations.of(context)!.loadingBenefits,
                  textAlign: TextAlign.center),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _userBenefitListItem(benefit) {
    return Container(
        child: Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(benefit.iconurl),
          backgroundColor: Colors.white10,
          radius: 28.0,
        ),
        Text(benefit.title ?? AppLocalizations.of(context)!.unnamed)
      ],
    ));
  }
}
