import 'package:flutter/material.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class EventLogView extends StatefulWidget {
  final String viewTitle = 'eventlog';
  @override
  _EventLogViewState createState() => _EventLogViewState();
}

class _EventLogViewState extends State<EventLogView> {
  @override
  Widget build(BuildContext context) {
    Future<List<String>?> getEventLog() => EventLog().getMessages();
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(AppLocalizations.of(context)!.eventLog)),
      body: FutureBuilder(
        initialData: [],
          future: getEventLog(),
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.data!=null && snapshot.data.length>0){
              List<String> messages = snapshot.data ?? [];
              return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {

                return ListTile(
                    title: Text(messages[index].toString()),
                );
              });
            }
            else return ListTile(
              title: Text(AppLocalizations.of(context)!.logIsEmpty),
            );
          }
      ),
    );
  }
}