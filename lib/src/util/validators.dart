String? validateEmail(String? value) {
  String? _msg;
  RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (value!.isEmpty) {
    _msg = "Your username is required";
  } else if (!regex.hasMatch(value)) {
    _msg = "Please provide a valid email address";
  }
  return _msg;
}

String? validateContact(String? value)
{

  String? _msg;
  if(value!.isEmpty) return 'Please enter your phone number or email address';

  //test for phone number pattern
  String pattern = r'(^(?:[+0])?[0-9]{8,15}$)';
  RegExp regExp = new RegExp(pattern);
  if (regExp.hasMatch(value)) {
    return null;
  }
  //test for email pattern
  RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (!regex.hasMatch(value)) {
    _msg = "Please provide a valid email address or phone number";
  }
  return _msg;
}