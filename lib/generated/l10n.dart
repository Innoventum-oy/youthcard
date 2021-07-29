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

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Account created`
  String get accountCreated {
    return Intl.message(
      'Account created',
      name: 'accountCreated',
      desc: '',
      args: [],
    );
  }

  /// `Activities`
  String get activities {
    return Intl.message(
      'Activities',
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

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
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

  /// `Continue`
  String get btnContinue {
    return Intl.message(
      'Continue',
      name: 'btnContinue',
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

  /// `Return`
  String get btnReturn {
    return Intl.message(
      'Return',
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

  /// `Use Email`
  String get btnUseEmail {
    return Intl.message(
      'Use Email',
      name: 'btnUseEmail',
      desc: '',
      args: [],
    );
  }

  /// `Use Phone number`
  String get btnUsePhone {
    return Intl.message(
      'Use Phone number',
      name: 'btnUsePhone',
      desc: '',
      args: [],
    );
  }

  /// `Validate contact information now`
  String get btnValidateContact {
    return Intl.message(
      'Validate contact information now',
      name: 'btnValidateContact',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get btnValidateContactLater {
    return Intl.message(
      'Later',
      name: 'btnValidateContactLater',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message(
      'Calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get clearCache {
    return Intl.message(
      'Clear cache',
      name: 'clearCache',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Code scanned`
  String get codeScanned {
    return Intl.message(
      'Code scanned',
      name: 'codeScanned',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPassword {
    return Intl.message(
      'Confirm password',
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

  /// `Contact information`
  String get contactInformation {
    return Intl.message(
      'Contact information',
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

  /// `Discover`
  String get discover {
    return Intl.message(
      'Discover',
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

  /// `Environment`
  String get environment {
    return Intl.message(
      'Environment',
      name: 'environment',
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

  /// `First name`
  String get firstName {
    return Intl.message(
      'First name',
      name: 'firstName',
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

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get lastName {
    return Intl.message(
      'Last name',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Loading benefits`
  String get loadingBenefits {
    return Intl.message(
      'Loading benefits',
      name: 'loadingBenefits',
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

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `More information`
  String get moreInformation {
    return Intl.message(
      'More information',
      name: 'moreInformation',
      desc: '',
      args: [],
    );
  }

  /// `My activities`
  String get myActivities {
    return Intl.message(
      'My activities',
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

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
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

  /// `Pause`
  String get pause {
    return Intl.message(
      'Pause',
      name: 'pause',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phoneNumber {
    return Intl.message(
      'Phone number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Phone or Email`
  String get phoneOrEmail {
    return Intl.message(
      'Phone or Email',
      name: 'phoneOrEmail',
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

  /// `Postcode`
  String get postcode {
    return Intl.message(
      'Postcode',
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

  /// `Processing`
  String get processing {
    return Intl.message(
      'Processing',
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

  /// `Scanner ready`
  String get readyToScan {
    return Intl.message(
      'Scanner ready',
      name: 'readyToScan',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get settingsAccount {
    return Intl.message(
      'Account',
      name: 'settingsAccount',
      desc: '',
      args: [],
    );
  }

  /// `Common`
  String get settingsCommon {
    return Intl.message(
      'Common',
      name: 'settingsCommon',
      desc: '',
      args: [],
    );
  }

  /// `Misc`
  String get settingsMisc {
    return Intl.message(
      'Misc',
      name: 'settingsMisc',
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

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
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

  /// `Unnamed`
  String get unnamed {
    return Intl.message(
      'Unnamed',
      name: 'unnamed',
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

  /// `Validate contact information`
  String get validateContactTitle {
    return Intl.message(
      'Validate contact information',
      name: 'validateContactTitle',
      desc: '',
      args: [],
    );
  }

  /// `Contact information validated`
  String get contactInformationValidated {
    return Intl.message(
      'Contact information validated',
      name: 'contactInformationValidated',
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

  /// `Youth Card Settings`
  String get youthcardSettings {
    return Intl.message(
      'Youth Card Settings',
      name: 'youthcardSettings',
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
      Locale.fromSubtags(languageCode: 'cs'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fi'),
      Locale.fromSubtags(languageCode: 'hr'),
      Locale.fromSubtags(languageCode: 'pt'),
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
