// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `about`
  String get about {
    return Intl.message(
      'about',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `activities`
  String get activities {
    return Intl.message(
      'activities',
      name: 'activities',
      desc: '',
      args: [],
    );
  }

  /// `Activity calendar`
  String get activityCalendar {
    return Intl.message(
      'Activity calendar',
      name: 'activityCalendar',
      desc: '',
      args: [],
    );
  }

  /// `address`
  String get address {
    return Intl.message(
      'address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Authenticating ... Please wait`
  String get authenticating {
    return Intl.message(
      'Authenticating ... Please wait',
      name: 'authenticating',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get btnLogin {
    return Intl.message(
      'Login',
      name: 'btnLogin',
      desc: '',
      args: [],
    );
  }

  /// `return`
  String get btnReturn {
    return Intl.message(
      'return',
      name: 'btnReturn',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get btnSend {
    return Intl.message(
      'Send',
      name: 'btnSend',
      desc: '',
      args: [],
    );
  }

  /// `Set Password`
  String get btnSetNewPassword {
    return Intl.message(
      'Set Password',
      name: 'btnSetNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `calendar`
  String get calendar {
    return Intl.message(
      'calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `cancel`
  String get cancel {
    return Intl.message(
      'cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `city`
  String get city {
    return Intl.message(
      'city',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `code scanned`
  String get codeScanned {
    return Intl.message(
      'code scanned',
      name: 'codeScanned',
      desc: '',
      args: [],
    );
  }

  /// `confirm password`
  String get confirmPassword {
    return Intl.message(
      'confirm password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation key`
  String get confirmationKey {
    return Intl.message(
      'Confirmation key',
      name: 'confirmationKey',
      desc: '',
      args: [],
    );
  }

  /// `contact information`
  String get contactInformation {
    return Intl.message(
      'contact information',
      name: 'contactInformation',
      desc: '',
      args: [],
    );
  }

  /// `Create account`
  String get createAccount {
    return Intl.message(
      'Create account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `discover`
  String get discover {
    return Intl.message(
      'discover',
      name: 'discover',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Email or Phone number`
  String get emailOrPhoneNumber {
    return Intl.message(
      'Email or Phone number',
      name: 'emailOrPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Event Log`
  String get eventLog {
    return Intl.message(
      'Event Log',
      name: 'eventLog',
      desc: '',
      args: [],
    );
  }

  /// `Errors in form contents`
  String get errorsInForm {
    return Intl.message(
      'Errors in form contents',
      name: 'errorsInForm',
      desc: '',
      args: [],
    );
  }

  /// `Flash On`
  String get flashOn {
    return Intl.message(
      'Flash On',
      name: 'flashOn',
      desc: '',
      args: [],
    );
  }

  /// `Flash Off`
  String get flashOff {
    return Intl.message(
      'Flash Off',
      name: 'flashOff',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Front Camera`
  String get frontCamera {
    return Intl.message(
      'Front Camera',
      name: 'frontCamera',
      desc: '',
      args: [],
    );
  }

  /// `Get code`
  String get getCode {
    return Intl.message(
      'Get code',
      name: 'getCode',
      desc: '',
      args: [],
    );
  }

  /// `loading`
  String get loading {
    return Intl.message(
      'loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get loginFailed {
    return Intl.message(
      'Login failed',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `logout`
  String get logout {
    return Intl.message(
      'logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `more information`
  String get moreInformation {
    return Intl.message(
      'more information',
      name: 'moreInformation',
      desc: '',
      args: [],
    );
  }

  /// `my activities`
  String get myActivities {
    return Intl.message(
      'my activities',
      name: 'myActivities',
      desc: '',
      args: [],
    );
  }

  /// `My Card`
  String get myCard {
    return Intl.message(
      'My Card',
      name: 'myCard',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get password {
    return Intl.message(
      'password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Password changed`
  String get passwordChanged {
    return Intl.message(
      'Password changed',
      name: 'passwordChanged',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get passwordIsRequired {
    return Intl.message(
      'Password is required',
      name: 'passwordIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `pause`
  String get pause {
    return Intl.message(
      'pause',
      name: 'pause',
      desc: '',
      args: [],
    );
  }

  /// `phone`
  String get phone {
    return Intl.message(
      'phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Please complete the form properly`
  String get pleaseCompleteFormProperly {
    return Intl.message(
      'Please complete the form properly',
      name: 'pleaseCompleteFormProperly',
      desc: '',
      args: [],
    );
  }

  /// `Please enter password`
  String get pleaseEnterPassword {
    return Intl.message(
      'Please enter password',
      name: 'pleaseEnterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter confirmation key`
  String get pleaseEnterConfirmationKey {
    return Intl.message(
      'Please enter confirmation key',
      name: 'pleaseEnterConfirmationKey',
      desc: '',
      args: [],
    );
  }

  /// `Registering account, please wait`
  String get pleaseWaitRegistering {
    return Intl.message(
      'Registering account, please wait',
      name: 'pleaseWaitRegistering',
      desc: '',
      args: [],
    );
  }

  /// `postcode`
  String get postcode {
    return Intl.message(
      'postcode',
      name: 'postcode',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previous {
    return Intl.message(
      'Previous',
      name: 'previous',
      desc: '',
      args: [],
    );
  }

  /// `processing`
  String get processing {
    return Intl.message(
      'processing',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `QR Scanner`
  String get qrScanner {
    return Intl.message(
      'QR Scanner',
      name: 'qrScanner',
      desc: '',
      args: [],
    );
  }

  /// `Read more`
  String get readMore {
    return Intl.message(
      'Read more',
      name: 'readMore',
      desc: '',
      args: [],
    );
  }

  /// `Rear Camera`
  String get rearCamera {
    return Intl.message(
      'Rear Camera',
      name: 'rearCamera',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed`
  String get registrationFailed {
    return Intl.message(
      'Registration failed',
      name: 'registrationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Request failed`
  String get requestFailed {
    return Intl.message(
      'Request failed',
      name: 'requestFailed',
      desc: '',
      args: [],
    );
  }

  /// `Get new code`
  String get requestNewCode {
    return Intl.message(
      'Get new code',
      name: 'requestNewCode',
      desc: '',
      args: [],
    );
  }

  /// `Get new Password`
  String get requestNewPasswordTitle {
    return Intl.message(
      'Get new Password',
      name: 'requestNewPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get resume {
    return Intl.message(
      'Resume',
      name: 'resume',
      desc: '',
      args: [],
    );
  }

  /// `Retrieving coordinates`
  String get retrievingCoordinates {
    return Intl.message(
      'Retrieving coordinates',
      name: 'retrievingCoordinates',
      desc: '',
      args: [],
    );
  }

  /// `Scan Code`
  String get scanCode {
    return Intl.message(
      'Scan Code',
      name: 'scanCode',
      desc: '',
      args: [],
    );
  }

  /// `settings`
  String get settings {
    return Intl.message(
      'settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed activity`
  String get unnamedActivity {
    return Intl.message(
      'Unnamed activity',
      name: 'unnamedActivity',
      desc: '',
      args: [],
    );
  }

  /// `unknown user`
  String get unknownUser {
    return Intl.message(
      'unknown user',
      name: 'unknownUser',
      desc: '',
      args: [],
    );
  }

  /// `Youth Card Login`
  String get youthcardLoginTitle {
    return Intl.message(
      'Youth Card Login',
      name: 'youthcardLoginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Youth Card`
  String get youthcardDashboard {
    return Intl.message(
      'Youth Card',
      name: 'youthcardDashboard',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
