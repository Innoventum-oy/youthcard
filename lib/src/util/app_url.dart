import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppUrl {
  static const Map<String,String> servers = {
    'Nuortenjoensuu' : 'nuortenjoensuu.fi',
    'Nuortenliperi' : 'nuortenliperi.fi',
 //   'Kontiolahti' : 'kontiolahti.harrastuskalenteri.fi',
  //  'Pirkkala'  : 'nuortenpirkkala.fi',
   // 'Lousada' : 'lousada.youthcard.pt',
  //  'Dresden' : 'dresden-youthcard.de',
 //   'Czech Republic' : 'youthcard.cz',
   // 'Medjimurje' : 'medimurje.youthcard.eu',
   if(kDebugMode) 'Kehitys' : 'nuortenjoensuu.webweb.fi'

  };
  static const Map<String,String> serverImages = {
    'Nuortenjoensuu' : 'images/nuortenjoensuu.png',
    'Nuortenliperi' : 'images/nuortenliperi.png',
//    'Lousada' : 'images/lousada.png',
 //   'Kontiolahti': 'images/kontiolahti.png',
  //  'Pirkkala' : 'images/pirkkala-logo.png'
  };
  static const Map<String,Color> backgroundColors = {
 //   'Kontiolahti' : Color.fromRGBO(93, 176, 51, 0.86),
  //  'Pirkkala' : Color.fromRGBO(18,92,79,1)
  };
  static const Map<String,String> serverToLanguageMapping = {
    'fi':'Nuortenjoensuu',

  //  'pt':'Lousada',
   // 'de':'Dresden',
   // 'cz':'Czech Republic'

  };
 static const Map<String,String> anonymousApikeys = {
   'Nuortenjoensuu':'\$2y\$10\$PEXtBKieZfKREBW/ofsXu.dSofZ19rZSZgi87gjDT.MXheQrx7qm2',
   'Nuortenliperi':'\$2y\$10\$2V1D67i59auPdJO3SDZfounahm6zEmy3rO8U5NC3gqDs0OSpW7/3a',
   //'Kontiolahti' :'\$2y\$10\$2V1D67i59auPdJO3SDZfounahm6zEmy3rO8U5NC3gqDs0OSpW7/3a',
   'Development':'\$2y\$10\$PEXtBKieZfKREBW/ofsXu.dSofZ19rZSZgi87gjDT.MXheQrx7qm2',
  // 'Lousada':'\$2y\$10\$2V1D67i59auPdJO3SDZfounahm6zEmy3rO8U5NC3gqDs0OSpW7/3a',
   //'Dresden': '\$2y\$10\$9K0fvauckPBRPaQc.fHFNO89WiKkX7xKGZAIAAzLmgpAqdN/Ymy/6',
   //'Czech Republic': '\$2y\$10\$BCuPRRLN276mqCGl4MpzFOelx/yjTB/B/9DD6hqmGy.6KQemiOk4O',
   //'Pirkkala' : '\$2y\$10\$2V1D67i59auPdJO3SDZfounahm6zEmy3rO8U5NC3gqDs0OSpW7/3a'
 };
  static const String liveBaseURL = "nuortenjoensuu.fi";
  static const String localBaseURL = "http://10.0.2.2:4000/api/";

  static const String baseURL = liveBaseURL;
  static const String login = "/api/login";
  static const String logout = "/api/logout";
  static const String registration =  "/api/register";
  static const String forgotPassword =  "/api/forgot-password";
  static const String requestValidationToken = "/api/dispatcher/registration/";
  static const String checkValidationToken = "/api/dispatcher/registration/";
  static const String getContactMethods = "/api/dispatcher/registration/";

}