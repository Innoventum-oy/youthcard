import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
//import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';

//geolocator for user location
import 'package:geolocator/geolocator.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/objectprovider.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/views/activity/activityvisitlist.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youth_card/src/util/shared_preference.dart';
//queuing mechanism
import 'package:queue/queue.dart';
//API client
import 'package:youth_card/src/util/api_client.dart';

const flashOn = 'flashOn';
const flashOff = 'flashOff';
const frontCamera = 'frontCamera';
const backCamera = 'rearCamera';

class QRScanner extends StatefulWidget {
  final Activity? activity;

  QRScanner({
    this.activity,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool canShowQRScanner = false;
  String? sentcode;
  List<String> codeQueue=[];
  final queue = Queue(delay: const Duration(milliseconds: 100));
  Future<Position>? _currentPosition;
  String? _latitude;
  String? _longitude;
  //String? _currentAddress;
  Barcode? result;
  var flashState = flashOn;
  var cameraState = frontCamera;
  bool isPaused = false;
  User user = new User();
  List<Activity> myActivities=[];
  Activity selectedActivity = new Activity();
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Geolocator geolocator = Geolocator();
  final ApiClient _apiClient = ApiClient();
  Timer? _timer;

  /* Returns user location in Position object for storing GPS coordinates where code was scanned */
  Future<Position> _getCurrentLocation() async {

    print('retrieving current location');

    var location = await Geolocator.getCurrentPosition();
    _latitude = location.latitude.toString();
    _longitude = location.longitude.toString();
    print('location retrieved');
    return location;
  }

  // User user;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      if(controller!=null) controller!.pauseCamera().catchError((error) {
        print(error.toString());
        notify(error.toString());
      });
    } else if (Platform.isIOS) {
      if(controller!=null)
      controller!.resumeCamera().catchError((error) {
        print(error.toString());
        notify(error.toString());
      });
    }
  }

  //notification using alertdialog

  void showMessage(BuildContext context, String title, Widget content) {
    showDialog(context: context, builder: (BuildContext builderContext) {
      _timer = Timer(Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        //backgroundColor: Colors.red,
        title: Text(title),
        content: SingleChildScrollView(
          child: content,
        ),
      );
    }
    ).then((val) {
      if (_timer!.isActive) {
        _timer!.cancel();
      }
    });
  }

  //Simple notification using snackBar

  notify(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //Send scanner data to server

  Future dataRequest(scannedcode) async
  {
    print('called dataRequest for code '+scannedcode.code);
    User user = Provider.of<UserProvider>(context,listen:false).user;
    Map<String, String> params = {
      'action': 'handleqr',
      'qr': scannedcode.code,
      'scansource': 'app',
      'method': 'json',
      'latitude': _latitude.toString(),
      'longitude': _longitude.toString(),
      'api_key' : user.token.toString()
    };
    print('CURRENT ACTIVITY: '+selectedActivity.id.toString());
    if (selectedActivity.id != null)
      params['activityid'] = selectedActivity.id.toString();
    //for debugging: print params
    params.forEach((key, value) {
      print('$key = $value');
    });
    print('Sending scanned code ' + scannedcode.code );

    print('Using latitude ' + _latitude! + ', longitude ' + _longitude!);

    //dispatcherrequest returns received JSON data or false
    dynamic response = await _apiClient.dispatcherRequest('activity', params);
    this.setState(() {
      if(response==false)
        {
          print('re-queuing code '+scannedcode.code);
          queue.add(()=>dataRequest(scannedcode));
        }
      else{
        //todo: add message types to eventlog
        //Wait for 5 seconds before removing the code
        Timer t = Timer(Duration(seconds: 5), () => codeQueue.remove(scannedcode.code));


        if (response['message'] != null) {
          List<Widget> texts = [ Text(response['message'])];
          if(response['benefits']!=null){
            texts.add(Text(AppLocalizations.of(context)!.benefits));
            for(var benefit in response['benefits'])
            texts.add(Text(benefit));
          }
          Widget content = Column(children:[
            if(response['picture']!=null) Image.network(response['picture']),
           ...texts,

          ]);
          showMessage(context,AppLocalizations.of(context)!.visitRecorded,content);
          String statusType = response['status'];
          switch(response['status']){
            case 'success':
              statusType = AppLocalizations.of(context)!.ok;
              break;
            case 'error':
           //   statusType = AppLocalizations.of(context)!.error;
              break;
          }
          EventLog().saveMessage(statusType+': '+response['message']+(response['benefits']!=null ? AppLocalizations.of(context)!.benefits+': '+ response['benefits'].join(','):'' ));
        }
      }

    });
  }

  // sendData reformatted to add scanned codes to codeQueue.

  Future<String> sendData(scannedcode) async {

    /* Todo: finalise position processing
    if (_currentPosition == null) {
      notify('Current position unknown, returning false from sendData. How to get the position first instead?');
      return "Error";
    }
  */

    if (!codeQueue.contains(scannedcode.code)) {
      codeQueue.add(scannedcode.code);
      notify(AppLocalizations.of(context)!.codeScanned);
    //  notify('Adding ' + scannedcode.code+' to queue');
      queue.add(()=>dataRequest(scannedcode));
    } else {
      //notify('code ' + scannedcode.code + ' already in server queue, returning false from sendData');
      return 'error';
    }

    return "Success";
  }

  //todo: move this to locationprovider or some util
/*
  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
*/


  @override
  void initState() {
    print('initState called for QRscanner');
    _currentPosition = _getCurrentLocation();
    //get the user
    User user = Provider.of<UserProvider>(context, listen: false).user;

    if(widget.activity!=null && selectedActivity.id==null) {
     print('widget called with activity '+(widget.activity!.name ?? ''));
      selectedActivity = widget.activity!;
    }
    else { //set the user for activitylistprovider
      ActivityListProvider alp = Provider.of<ActivityListProvider>(context, listen: false);
      alp.setUser(user);
      alp.loadMyItems();
    }
    getCameraPermission();
    super.initState();
  }

  void getCameraPermission() async {

    var status = await Permission.camera.status;
    print('Camera status: '+status.toString()); // prints PermissionStatus.granted
    if (!status.isGranted) {
      print('creating permission request');
      final result = await Permission.camera.request();
      print('request result:' +result.toString());
      if (result.isGranted) {
        setState(() {
          canShowQRScanner = true;
        });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Camera Permission'),
              content: Text(
                  AppLocalizations.of(context)!.pleaseEnableCamera),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.noThankYou),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.settings),
                  onPressed: () => openAppSettings(),
                ),
              ],
            ));

      }
    } else {
      setState(() {
        canShowQRScanner = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    print('build called for QRscanner');
    //set up to date user in build
    this.user = Provider.of<UserProvider>(context).user;

    myActivities = Provider.of<ActivityListProvider>(context).list ??[];

    String titleText = AppLocalizations.of(context)!.qrScanner;

    bool isTester = false;
    if(user.data!=null) {

      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }
    Widget activitySelect = Container();

    if (widget.activity != null) {
      titleText += '\n' + widget.activity!.name!;
      print('Current activity: '+(widget.activity!.name ?? 'Not set'));
    } else if (myActivities.isNotEmpty ) {
      if(selectedActivity.id==null) {
        //set default selection
        selectedActivity = myActivities.first;
      }

      activitySelect = DropdownButton<Activity>(
        value: selectedActivity,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (Activity? newValue) {
          setState(() {
            selectedActivity = newValue!;
          });
        },
        items: myActivities
            .map<DropdownMenuItem<Activity>>((Activity activity) {
          print('adding item ' + activity.id.toString() + ' to dropdown menu');
          return DropdownMenuItem<Activity>(
            value: activity,
            child: Text(activity.name ?? 'No name ' + activity.id.toString()),
          );
        }).toList(),
      );
    }

print('returning scaffold');
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(titleText),
            elevation: 0.1,
            actions: [
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    print('Refreshing view');
                    setState(() {


                    });
                  }),
              if(isTester) IconButton(
                  icon: Icon(Icons.bug_report),
                  onPressed:(){feedbackAction(context,user); }
              ),
             if(selectedActivity.id!=null) IconButton(
                  icon: Icon(Icons.book),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ActivityVisitList(selectedActivity)),
                     // MaterialPageRoute(builder: (context) => EventLogView()),
                    );
                  })
            ],
          ),
          body: Column(
            children: <Widget>[
              if(widget.activity==null && myActivities.isNotEmpty) activitySelect,//Text('You have 0 activities '+(this.user.firstname ?? 'anonymous dude')),
              // QR Scanner section
              Expanded(flex: 4, child:canShowQRScanner ? _buildQrView(context) : ListTile(
                  leading: Icon(Icons.error),
                  title: Text(AppLocalizations.of(context)!
                  .cameraNotAvailable),),
              ),
              //lower section
              if(canShowQRScanner && controller!=null )Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FutureBuilder(
                          future: _currentPosition,
                          builder: (context, data) {
                            if (data.hasData) {
                              print('location retrieved for futurebuilder: ' +
                                  data.data.toString());
                              return Row(children:[
                                Icon(Icons.check_circle_outlined),
                                Text(AppLocalizations.of(context)!
                                    .locationRetrieved)
                              ]);
                            } else {
                              return Row(children: [
                                CircularProgressIndicator(),
                                Text(AppLocalizations.of(context)!
                                    .retrievingCoordinates),
                              ]);
                            }
                          }),
                      if (result != null)
                        Text(AppLocalizations.of(context)!.codeScanned,style: TextStyle(fontSize: 20))
                      else
                        Text(AppLocalizations.of(context)!.readyToScan,style: TextStyle(fontSize: 20)),
                      // Text(codeQueue.length.toString()+' items in queue'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton.icon(
                              icon: Icon(flashState == flashOff
                                  ? Icons.flash_on
                                  : Icons.flash_off),
                              onPressed: () {
                                if (controller != null) {
                                  controller!.toggleFlash().catchError((error) {
                                    //print(error.toString());
                                    notify(error.toString());
                                  });

                                  if (_isFlashOn(flashState)) {
                                    setState(() {
                                      flashState = flashOff;
                                    });
                                  } else {
                                    setState(() {
                                      flashState = flashOn;
                                    });
                                  }
                                }
                              },
                              label: Text(
                                  flashState == flashOff
                                      ? AppLocalizations.of(context)!.flashOff
                                      : AppLocalizations.of(context)!.flashOn,
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () {
                                if (controller != null) {
                                  controller!.flipCamera().catchError((error) {
                                    print(error.toString());
                                    notify(error.toString());
                                  });
                                  if (_isBackCamera(cameraState)) {
                                    setState(() {
                                      cameraState = frontCamera;
                                    });
                                  } else {
                                    setState(() {
                                      cameraState = backCamera;
                                    });
                                  }
                                }
                              },
                              child: Text(
                                  cameraState == backCamera
                                      ? AppLocalizations.of(context)!.frontCamera
                                      : AppLocalizations.of(context)!.rearCamera,
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          if(!isPaused)Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.pause),
                              onPressed: () {
                                controller?.pauseCamera().then((value){
                                  setState(() {
                                    isPaused = true;
                                  });
                                }).catchError((error) {
                                  print(error.toString());
                                  notify(error.toString());
                                });
                              },
                              label: Text(AppLocalizations.of(context)!.pause,
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          if(isPaused) Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                controller?.resumeCamera().then((value){
                                  setState(() {
                                    isPaused = false;
                                  });
                                }).catchError((error) {
                                  print(error.toString());
                                  notify(error.toString());
                                });
                              },
                              label: Text(AppLocalizations.of(context)!.resume,
                                  style: TextStyle(fontSize: 20)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }


  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  Widget _buildQrView(BuildContext context) {
    // fit the scanArea depending on the device screen measurements
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sized after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return canShowQRScanner ?  QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    ): Padding(
      padding:EdgeInsets.all(20),
      child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
      children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        children:[
        Icon(Icons.error),
        Text(AppLocalizations.of(context)!.cameraNotAvailable),
      ]
          ),
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.btnReturn),
          onPressed: () => Navigator.of(context).pop(),
        )
    ]),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    if(controller.hasPermissions)
    controller.scannedDataStream.listen((scanData) {
      if (!codeQueue.contains(scanData.code))
        setState(() {
          result = scanData;
          notify(AppLocalizations.of(context)!.codeScanned);
          sendData(result);
        });
    });
  }

  @override
  void dispose() {
    if(controller!=null)
    controller!.dispose();
    super.dispose();
  }
}
