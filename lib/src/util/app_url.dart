class AppUrl {
  static const Map<String,String> servers = {
    'Nuortenjoensuu' : 'nuortenjoensuu.fi',
    'Lousada' : 'lousada.youthcard.pt',
    'Dresden' : 'dresden-youthcard.de',
    'Czech Republic' : 'youthcard.cz',
    'Medjimurje' : 'medimurje.youthcard.eu',
    'Development' : 'nuortenjoensuu.webweb.fi'
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