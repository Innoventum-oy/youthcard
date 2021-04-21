import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';
//geolocator for user location
import 'package:geolocator/geolocator.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/objects/user.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/user_provider.dart';
//void main() => runApp(MaterialApp(home: QRScanner()));

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class QRScanner extends StatefulWidget {
  const QRScanner({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  String? sentcode;
  Future<Position>? _currentPosition;
  String? _latitude;
  String? _longitude;
  String? _currentAddress;
  Barcode? result;
  var flashState = flashOn;
  var cameraState = frontCamera;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Geolocator geolocator = Geolocator();
 // User user;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }
  Notify(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
    Future<String> sendData(scannedcode) async {
    Map map;
    User user = Provider.of<UserProvider>(context,listen: false).user;



    if(_currentPosition == null){
      Notify('Current position unknown, returning false from sendData. How to get the position first instead?');
      return "Error";
    }

    if(user== null){
      Notify('user is not set for sendData, returning false. Why is user not set?');
      print(user);
      return "error";
    }
    if(sentcode!=scannedcode.code) {
      sentcode = scannedcode.code;
      print('setting sentcode to '+scannedcode.code);
    }
    else {
      print('code ' + sentcode! + ' already sent to server, returning false from sendData');
      return 'error';
    }
    Map<String, String> params ={
       'action': 'handleqr',
        'qraction': 'scanactivity',
        'qr':scannedcode.code,
        'scansource':'app',
      'method':'json',
        'latitude': _latitude.toString(),
        'longitude':  _longitude.toString()

    };
   ;
    var url = Uri.https(AppUrl.baseURL,'/api/dispatcher/activity/',params);
    print('Sending scanned code '+scannedcode.code+' to url '+url.toString()+', using token '+user.token!);
    print('Using latitude '+_latitude!+', longitude '+_longitude!);
    var response = await http.get(url,headers:{ 'api_key':user.token!});

    this.setState(() {
      if(response.body.isNotEmpty) {
        print('received data ' + response.body);
        map = json.decode(response.body);
       Notify(map['message']);

      }
      else print('no response received for request');
      print('Unsetting sentcode');
      sentcode = null;

    });


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
  Future<Position>_getCurrentLocation() async {
    print('retrieving current location');
   var Location = await Geolocator.getCurrentPosition();
    _latitude = Location.latitude.toString();
    _longitude = Location.longitude.toString();
    return Location;
  }

  @override
  void initState() {
    _currentPosition = _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    User user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
        elevation: 0.1,
      ),
      body: Column(
        children: <Widget>[
          Row(),
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FutureBuilder(
                    future: _getCurrentLocation(),

                    builder: (context,data){
                      if(data.hasData) {
                        print('location retrieved for futurebuilder');
                        return Text(data.data.toString());
                      } else{
                        return  Row(children:[
                            CircularProgressIndicator(),
                            Text('Retrieving coordinates'),
                          ]
                           );
                      }
                    }
                  ),
                  if (result != null)
                    Text( 'Code Scanned ')
                  else
                    Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            if (controller != null) {
                              controller!.toggleFlash();
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
                          child:
                          Text(flashState, style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            if (controller != null) {
                              controller!.flipCamera();
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
                          child:
                          Text(cameraState, style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            controller?.pauseCamera();
                          },
                          child: Text('pause', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            controller?.resumeCamera();
                          },
                          child: Text('resume', style: TextStyle(fontSize: 20)),
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
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if(sentcode==null || sentcode != scanData.code)
      setState(() {
        result = scanData;
        sendData(result);


      });
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}