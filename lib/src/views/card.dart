import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youth_card/src/objects/contactmethod.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/userbenefit.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:youth_card/src/views/userform.dart';
/*
* User card
*/

class MyCard extends StatefulWidget {
  final User? user;
  final String viewTitle = 'usercard';
  //TODO: remove this provider and just read the benefits from user object, provided by loaduser (which also loads the benefits for user)
  final objectmodel.UserBenefitProvider userBenefitProvider =
      objectmodel.UserBenefitProvider();

  MyCard({this.user});

  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  List<UserBenefit> benefits = [];
  List<Widget> contactItems = [];
  List<ContactMethod> myContacts = [];
  LoadingState _benefitsLoadingState = LoadingState.LOADING;
  bool fieldsLoaded = false;
  bool userLoaded = false;
  int? objectId;
  Map<String,dynamic> fields = {};

  String? errormessage;
  User user = new User();

  /// Returns available fields information from server
  _getFields() async{

    UserProvider provider = UserProvider();
    //target user:
    int targetId = widget.user?.id ?? (Provider.of<UserProvider>(context, listen: false).user.id ?? 0);
    //  print('_getUserInfo called, retrieving user information from userprovider for user '+targetId.toString());
    dynamic fielddata = await provider.getFields(targetId, Provider.of<UserProvider>(context, listen: false).user);
    setState(() {
    print('user fields loaded');
      if(fielddata!=null) {
        this.fields = fielddata;
      }

      fieldsLoaded = true;

    });
  }

  /*
  Returns user information from server
   */
  _getUserInfo() async{

    UserProvider provider = UserProvider();
    //target user:
    int targetId = widget.user?.id ?? (Provider.of<UserProvider>(context, listen: false).user.id ?? 0);
    //  print('_getUserInfo called, retrieving user information from userprovider for user '+targetId.toString());
    dynamic userdata = await provider.getObject(targetId, Provider.of<UserProvider>(context, listen: false).user);
    setState(() {
      if(userdata!=null) {
        this.user = User.fromJson(userdata['data'].first['data'],description:userdata['description']);
      }
      print('user info loaded');
      userLoaded = true;
      _benefitsLoadingState = LoadingState.DONE;

      benefits = widget.user!.userbenefits;

    });
  }



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


        benefits.addAll(result);
       // print(result.length.toString() + ' benefits currently loaded!');
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
    this.user =widget.user ?? Provider.of<UserProvider>(context, listen: false).user;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      if(widget.user==null) {
        userLoaded = true;
        _loadBenefits(user);
      }
      else {
        this.user = widget.user as User;
       _getUserInfo();
      }
      _getFields();
    });
    super.initState();
  }

  Widget loader(context){
    return Align(
      alignment: Alignment.center,
      child: Center(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text(AppLocalizations.of(context)!.loading,
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = this.user;
    bool isTester = false;
    if(user.data!=null) {

      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }

    if(user.description!=null)
      {
        Map<String,dynamic> description = user.description ?? {};
        description.forEach((key, value){
          print(key+': '+value+' '+user.data![key].toString());
        });
      }else print('user description is NULL');

    contactItems.clear();
    contactItems.add(Padding(
      padding:EdgeInsets.all(10),
      child:Column(

        children:[
          if(user.email!=null) TextButton(

            onPressed:(){
              launchUrlString("mailto:"+(user.email??''));

            },
            child:
            SingleChildScrollView(
              child:Container(
                height: 30,
                child:Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  [
                    Icon(Icons.email),
                    Flexible(child: Text(user.email ??'-',
                      overflow: TextOverflow.clip,),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextButton(
            onPressed:(){
              launchUrlString("tel:"+(user.phone??''));
            },
            child: Container(
              height: 25,
              child: Row(
                  children:[
                    Icon(Icons.phone_android),
                    Text(user.phone??'-')
                  ]
              ),
            ),
          ),
          if(user.data!['huoltajan_puhelinnumero']!=null)
            TextButton(
              onPressed:(){
                launchUrlString("tel:"+(user.data!['huoltajan_puhelinnumero']??''));
              },
              child: Container(
                height: 25,
                child: Row(
                    children:[
                      Icon(Icons.phone_android),
                      Text(AppLocalizations.of(context)!.guardianPhone+': '+user.data!['huoltajan_puhelinnumero'])
                    ]
                ),
              ),
            ),
          if(user.accesslevel!= null && user.accesslevel! >= 20) ..._userInfoFields(user),
        ]),
    ),
    );
    return OrientationBuilder(builder: (context, orientation) {
      //  print(orientation);
      // Choose between portraitlayout and landscapelayout based on device orientation
      return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myCard),
            actions: [
              if(isTester) IconButton(
                  icon: Icon(Icons.bug_report),
                  onPressed:(){feedbackAction(context,user); }
              ),
            ],
            elevation: 0.1,
          ),
          body: orientation == Orientation.portrait
              ? _portraitLayout(user)
              : _landscapeLayout(user),
          bottomNavigationBar: bottomNavigation(context,currentIndex:2)
      );
    });
  }

  Widget _portraitLayout(user) {
    return ListView(
        shrinkWrap: true,
      children: [
        SizedBox(height: 20),
        Center(
            child: user.qrcode != null && user.qrcode!.isNotEmpty
                ? Image.network(user.qrcode!, height: 200)
                : Container()),
        SizedBox(height: 20),
        Center(child: _loggedInView(context, user)),
        ...this.contactItems,
        SizedBox(height: 20),
       // Text('Access:'+user.accesslevel.toString()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children:[
            if((user!.accesslevel!= null && user.accesslevel >= 20) ||(widget.user==null && Provider.of<UserProvider>(context, listen: false).user.id!=null)) ElevatedButton(
          onPressed : (){
            // notifyDialog('opening userform',context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>   UserForm(targetUser:user!),
              ),
            );

          },
          child: Text(AppLocalizations.of(context)!.btnEdit)
      ),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.btnReturn)),
        ]),
        _getBenefitsSection(user),
      //  ..._userInfoFields(user)
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
    var avatarImage;
    if(user.data!=null && user.data!['userimageurl'] != null && user.data!['userimageurl']!.isNotEmpty) avatarImage = NetworkImage(user.data!['userimageurl']);
    else if(user.image != null && user.image!.isNotEmpty) avatarImage = NetworkImage(user.image);
    else avatarImage =Image.asset('images/profile.png').image ;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _drawAvatar(avatarImage,
              user),

            _drawLabel(context, username),


        ],
      ),
    );
  }

  Widget _drawLabel(BuildContext context, String label) {
    return Flexible(
        child:
      Padding(
        padding: const EdgeInsets.all(16.0),
         child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge,
      ),
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
  List<Widget> _userInfoFields(user)
  {
    List<Widget> widgets = [];
    if(!(userLoaded && fieldsLoaded )) widgets.add(loader(context));
    else if(this.fields.length>0 )
    {
      Map<String,dynamic> userdata = this.user.toMap();

      Map<String,dynamic> fields = this.fields; // targetUser.description ?? {};


      user.data!.forEach((key,value) {
        print(key.toString()+':'+value.toString());
      });

      fields['fields'].forEach((name, definition) {
        dynamic value;
        if(userdata.containsKey(name)) {
          //  print('user has own property '+name+' with value '+userdata[name].toString());
          value = userdata[name];
        }
        else if( user.data!.containsKey(name)) {
          //print('user data includes '+name+' with value '+user.data![name].toString());
          value = user.data![name];
        }
        if(value==null) value = '-';
       // if(value != null) {

          widgets.add(
              Padding( padding:EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                 Expanded(
                   flex: 2,
                   child:Text(definition['displayname'] ?? name,
               //  overflow:TextOverflow.ellipsis,
                 style:TextStyle(fontWeight: FontWeight.bold)),),

                 Expanded(
                   flex: 3,
                   child: Text(value,
                    overflow: TextOverflow.clip,),
                  ),
                ],
                  ),
              )
          );
        // }

      });

    }
    return widgets;
  }
  Widget _getBenefitsSection(user) {
    print('_getBenefitsSection gets called');
    switch (_benefitsLoadingState) {
      case LoadingState.DONE:
        //data loaded

        return Container(
           height:50,
          child:Padding(
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
