String? validateEmail(String? value) {
  String? msg;
  RegExp regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (value!.isEmpty) {
    msg = "Your username is required";
  } else if (!regex.hasMatch(value)) {
    msg = "Please provide a valid email address";
  }
  return msg;
}

String? validateContact(String? value)
{

  String? msg;
  if(value!.isEmpty) return 'Please enter your phone number or email address';

  //test for phone number pattern
  String pattern = r'(^(?:[+0])?[0-9]{8,15}$)';
  RegExp regExp = RegExp(pattern);
  if (regExp.hasMatch(value)) {
    return null;
  }
  //test for email pattern
  RegExp regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (!regex.hasMatch(value)) {
    msg = "Please provide a valid email address or phone number";
  }
  return msg;
}