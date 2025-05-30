import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/formcategory.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:youth_card/src/views/displayform.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/index.dart' as object_model;
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/form.dart' as icms_form;
import 'package:youth_card/src/objects/formcategory.dart' as icms_form_category;
/*
* Forms list
*/

class FormList extends StatefulWidget {

  final object_model.FormCategoryProvider formCategoryProvider =
  object_model.FormCategoryProvider();
  final object_model.FormProvider formProvider =
  object_model.FormProvider();


  FormList({super.key});

  @override
  FormListState createState() => FormListState();
}
/*
class Item extends iCMSForm.Form {
  bool isExpanded = false;
  Item({id, title, description,isExpanded}) : super(id:id, title:title, description:description);

}
*/

class FormListState extends State<FormList> {

  List<Widget> categoryWidgets = [];
  List<icms_form_category.FormCategory> categories = [];
  List<icms_form.Form> tasks=[];

  bool categoriesLoaded = false;
  bool tasksLoaded = false;
  User? user;

  @override
  void initState(){

    loadFormCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if(!categoriesLoaded) {
        loadFormCategories();
      }
    });
    super.initState();
  }

  Future<void> loadForms(formCategory)
  async {

    User user = Provider.of<UserProvider>(context, listen: false).user;
    Map<String,dynamic> params={
      'status' :'active',
      'accesslevel' : 'read',
      'api_key': user.token ,

    };
    params['category']=formCategory.id.toString();

    if(formCategory.loadingStatus==LoadingStatus.idle) {
      formCategory.loadingStatus = LoadingStatus.loading;
      dynamic result = await widget.formProvider.loadItems(params);

      setState(() {

        formCategory.loadingStatus = LoadingStatus.ready;
        formCategory.forms.addAll(result);

      });
    }
    //else formCategory.tasksLoaded = true;
  }

  Future<void> loadFormCategories()
  async {

    Map<String,dynamic> params={
      'displayinapp' : 'true',
      'api_key': user?.token,
    };
    dynamic result = await widget.formCategoryProvider.loadItems(params);

    if(result!=null) {
      categories = result;
    }
    categoriesLoaded = true;
    if(categories.isNotEmpty)
    {
      for(icms_form_category.FormCategory c in categories) {
        setState(() {
          loadForms(c);
        });
        // Iterate tasks

      }
    }


  }

  @override
  Widget build(BuildContext context) {
    categoryWidgets.clear();
    user = Provider.of<UserProvider>(context).user;
    for(icms_form_category.FormCategory c in categories) {
      categoryWidgets.add(Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(c.name.toString(),style:TextStyle(fontSize:20)),
      ));
      categoryWidgets.add(_getTasks(c, user));
    }

    var loader=Align(
      alignment: Alignment.center,
      child: Center(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text(AppLocalizations.of(context)!.loading,
              textAlign: TextAlign.center),
        ),
      ),
    );

    bool isTester = false;
    if(user!.data!=null) {
      if (user!.data!['istester'] != null) {
        if (user!.data!['istester'] == 'true') isTester = true;
      }
    }
    return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.forms),
            elevation: 0.1,
            actions: [
              if(isTester) IconButton(
                  icon: Icon(Icons.bug_report),
                  onPressed:(){feedbackAction(context,user!); }
              ),
            ]
        ),
        body: ListView(
          children: <Widget>[

            if(categoriesLoaded) ...categoryWidgets,
            if(!categoriesLoaded) loader ,
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
        bottomNavigationBar: bottomNavigation(context)
    );
  } //widget

  Widget formItem(i)
  {
    return
      Row(

          children: [Expanded(
              flex: 1,
              child: Icon(Icons.view_list)),
            Expanded(
                flex: 4,
                child: Text(i.title.toString())
            ),
            Expanded(
                flex: 2,
                child: TextButton(
                  onPressed: () {

                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DisplayForm(i))
                    );

                  },

                  child: Text(
                    AppLocalizations.of(context)!.choose,
                    style: TextStyle(
                      // fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
            )

          ]
      );

  }

  Widget _getTasks(formCategory,user) {


    switch (formCategory.loadingStatus) {
      case LoadingStatus.ready:

      //data loaded
      // List<iCMSForm.Form> tasks = formCategory.forms;
        if(formCategory.forms.isEmpty) {
          return Align(alignment:Alignment.center,
            child:Center(
              child:ListTile(
                leading:Icon(Icons.info),
                title: Text(AppLocalizations.of(context)!.noFormsFound,textAlign: TextAlign.left),
              ),
            ),
          );
        }




        return ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            // print(isExpanded.toString());
            setState(() {
              formCategory.forms[index].isExpanded = !isExpanded;
            });
          },
          children: formCategory.forms.map<ExpansionPanel>((icms_form.Form form){
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title:Text(form.title.toString())
                );
              },
              body: ListTile(
                title: Text(form.description.toString()),
                trailing: ElevatedButton(
                  onPressed: () {

                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DisplayForm(form))
                    );

                  },

                  child: Text(
                    AppLocalizations.of(context)!.choose,
                    style: TextStyle(
                      // fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ),
              isExpanded:form.isExpanded,
            );
          }).toList(),
        );

      default:
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
  }

}
