import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/contactmethod.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/validatecontact.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
/*f
* Contact methods
*/

class ContactMethodsView extends StatefulWidget {
  const ContactMethodsView({super.key});

  @override
  _ContactMethodsViewState createState() => _ContactMethodsViewState();
}

class _ContactMethodsViewState extends State<ContactMethodsView> {
  List<Widget> contactItems = [];

  @override
  void initState(){
    print('initing ContactMethods view state');
    Provider.of<UserProvider>(context, listen: false).getContactMethods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding ContactMethods view');

    List<ContactMethod> myContacts = Provider.of<UserProvider>(context,listen:true).contacts;

    if(myContacts.isNotEmpty)
    {
      contactItems.clear();
      for(var i in myContacts)
      {
        print(i.toString());
        contactItems.add(
            Row(

                children:[Expanded(
                    flex:1,
                    child: Icon(i.type=='phone' ? Icons.phone_android :Icons.email)),
                  Expanded(
                      flex:4,
                      child: Text(i.address.toString())),
                  Expanded(
                      flex:2,
                      child:(i.verified! ? Icon(Icons.check_circle_outlined,semanticLabel:AppLocalizations.of(context)!.verified) : TextButton(
                        onPressed: () {
                          Provider.of<AuthProvider>(context,listen:false).setVerificationStatus(VerificationStatus.CodeNotRequested);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ValidateContact(contactmethod:i)),
                          );
                        },
                        child:Text(
                          AppLocalizations.of(context)!.verify ,
                          style: TextStyle(
                            // fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  )
                ]
            )
        );

      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.contactMethods),
        elevation: 0.1,
      ),
      body: Column(
        children: [

          SizedBox(height: 30),
          ...contactItems,

          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[
                Expanded(
                  child:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.btnReturn)
                    ),
                  ),
                ),


              ]
          ),

        ],
      ),
    );
  } //widget


}
