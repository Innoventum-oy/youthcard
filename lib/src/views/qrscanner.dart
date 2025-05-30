import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:async';
//import 'dart:convert';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

//geolocator for user location
import 'package:geolocator/geolocator.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/index.dart';

import 'package:youth_card/l10n/app_localizations.dart';
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

  const QRScanner({
    this.activity,
    super.key,
  });

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
  User user = User();
  List<Activity> myActivities=[];
  Activity selectedActivity = Activity();
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Geolocator geolocator = Geolocator();
  final ApiClient _apiClient = ApiClient();
  Timer? _timer;

  /* Returns user location in Position object for storing GPS coordinates where code was scanned */
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    try {
      var location = await Geolocator.getCurrentPosition();
      _latitude = location.latitude.toString();
      _longitude = location.longitude.toString();

      return location;
    }
    catch(e)
    {
      return Future.error('Error occurred in getting current position');
    }

  }

  // User user;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  @override
  void reassemble() {
    super.reassemble();
    if(controller!=null){
      if (Platform.isAndroid) {
        controller!.resumeCamera().catchError((error) {
          notify(error.toString());
          });
      }
      controller!.resumeCamera().catchError((error) {
        notify(error.toString());
      });
    }
  }

  //notification using alertdialog

  void showMessage(BuildContext context, String title, Widget content) {
    showDialog(context: context, builder: (BuildContext builderContext) {
      _timer = Timer(Duration(seconds: 5), () {
        Navigator.of(context, rootNavigator: true).maybePop();
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
   // print('CURRENT ACTIVITY: '+selectedActivity.id.toString());
    if (selectedActivity.id != null) {
      params['activityid'] = selectedActivity.id.toString();
    }

    //dispatcherrequest returns received JSON data or false
    dynamic response = await _apiClient.dispatcherRequest('activity', params);
    setState(() {
      if(response==false)
        {

          queue.add(()=>dataRequest(scannedcode));
        }
      else{
        //todo: add message types to eventlog
        //Wait for 5 seconds before removing the code
         Timer(Duration(seconds: 5), () => codeQueue.remove(scannedcode.code));


        if (response['message'] != null) {
          List<Widget> texts = [ Text(response['message'])];
          if(response['benefits']!=null){
            texts.add(Text(AppLocalizations.of(context)!.benefits));
            for(var benefit in response['benefits']) {
              texts.add(Text(benefit));
            }
          }
          Widget content = Column(children:[
            if(response['picture']!=null) Image.network(response['picture']),
           ...texts,

          ]);
          String messageTitle = response['status'] == 'success' ? AppLocalizations.of(context)!.visitRecorded : AppLocalizations.of(context)!.error;
          showMessage(context,messageTitle,content);
          String statusType = response['status'];
          switch(response['status']){
            case 'success':
              statusType = AppLocalizations.of(context)!.ok;
              break;
            case 'error':
           //   statusType = AppLocalizations.of(context)!.error;
              break;
          }
          EventLog().saveMessage('$statusType: '+response['message']+(response['benefits']!=null ? '${AppLocalizations.of(context)!.benefits}: '+ response['benefits'].join(','):'' ));
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
    _currentPosition = _getCurrentLocation();
    //get the user
    User user = Provider.of<UserProvider>(context, listen: false).user;

    if(widget.activity!=null && selectedActivity.id==null) {
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
    // prints PermissionStatus.granted
    if (!status.isGranted) {
      final result = await Permission.camera.request();
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
    //set up to date user in build
    user = Provider.of<UserProvider>(context).user;

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
      titleText += '\n${widget.activity!.name!}';
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
          //print('adding item ' + activity.id.toString() + ' to dropdown menu');
          return DropdownMenuItem<Activity>(
            value: activity,
            child: Text(activity.name ?? 'No name ${activity.id}'),
          );
        }).toList(),
      );
    }

//print('returning scaffold');
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(titleText),
            elevation: 0.1,
            actions: [
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
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
                                    notify(error.toString());
                                    return CameraFacing.back;
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
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    ) : Padding(
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
  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
  void _onQRViewCreated(QRViewController controller) {

    //print('qrview created');
    this.controller = controller;
    // if(controller.hasPermissions)
    controller.scannedDataStream.listen((scanData) {
      if (!codeQueue.contains(scanData.code)) {
        setState(() {
          result = scanData;
          notify(AppLocalizations.of(context)!.codeScanned);
          sendData(result);
        });
      }
    });

  }

}
