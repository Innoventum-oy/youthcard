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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
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

  /// `User account deleted`
  String get accountDeleted {
    return Intl.message(
      'User account deleted',
      name: 'accountDeleted',
      desc: '',
      args: [],
    );
  }

  /// `I acknowledge and accept that my information is saved to the database of the Sivulla application`
  String get accountCreationAccepted {
    return Intl.message(
      'I acknowledge and accept that my information is saved to the database of the Sivulla application',
      name: 'accountCreationAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Account Deletion`
  String get accountDeletion {
    return Intl.message(
      'Account Deletion',
      name: 'accountDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Activities`
  String get activities {
    return Intl.message('Activities', name: 'activities', desc: '', args: []);
  }

  /// `Activity`
  String get activity {
    return Intl.message('Activity', name: 'activity', desc: '', args: []);
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

  /// `Registration saved`
  String get activityRegistrationSaved {
    return Intl.message(
      'Registration saved',
      name: 'activityRegistrationSaved',
      desc: '',
      args: [],
    );
  }

  /// `Registering for activity failed`
  String get activityRegistrationFailed {
    return Intl.message(
      'Registering for activity failed',
      name: 'activityRegistrationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Are you 18+ years old?`
  String get ageOver18 {
    return Intl.message(
      'Are you 18+ years old?',
      name: 'ageOver18',
      desc: '',
      args: [],
    );
  }

  /// `I agree on saving my information`
  String get agreeOnSavingInfo {
    return Intl.message(
      'I agree on saving my information',
      name: 'agreeOnSavingInfo',
      desc: '',
      args: [],
    );
  }

  /// `Answer saved`
  String get answerSaved {
    return Intl.message(
      'Answer saved',
      name: 'answerSaved',
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

  /// `Benefits`
  String get benefits {
    return Intl.message('Benefits', name: 'benefits', desc: '', args: []);
  }

  /// `Confirm`
  String get btnConfirm {
    return Intl.message('Confirm', name: 'btnConfirm', desc: '', args: []);
  }

  /// `Continue`
  String get btnContinue {
    return Intl.message('Continue', name: 'btnContinue', desc: '', args: []);
  }

  /// `Skip login`
  String get btnContinueWithoutLogin {
    return Intl.message(
      'Skip login',
      name: 'btnContinueWithoutLogin',
      desc: '',
      args: [],
    );
  }

  /// `Open Dashboard`
  String get btnDashboard {
    return Intl.message(
      'Open Dashboard',
      name: 'btnDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get btnEdit {
    return Intl.message('Edit', name: 'btnEdit', desc: '', args: []);
  }

  /// `Login`
  String get btnLogin {
    return Intl.message('Login', name: 'btnLogin', desc: '', args: []);
  }

  /// `Return`
  String get btnReturn {
    return Intl.message('Return', name: 'btnReturn', desc: '', args: []);
  }

  /// `Send`
  String get btnSend {
    return Intl.message('Send', name: 'btnSend', desc: '', args: []);
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
    return Intl.message('Use Email', name: 'btnUseEmail', desc: '', args: []);
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

  /// `No camera available`
  String get cameraNotAvailable {
    return Intl.message(
      'No camera available',
      name: 'cameraNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message('Calendar', name: 'calendar', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Changes saved`
  String get changesSaved {
    return Intl.message(
      'Changes saved',
      name: 'changesSaved',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get choose {
    return Intl.message('Select', name: 'choose', desc: '', args: []);
  }

  /// `Choose file`
  String get chooseFile {
    return Intl.message('Choose file', name: 'chooseFile', desc: '', args: []);
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `Clear cache`
  String get clearCache {
    return Intl.message('Clear cache', name: 'clearCache', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
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

  /// `Confirm user account deletion`
  String get confirmDeletingAccount {
    return Intl.message(
      'Confirm user account deletion',
      name: 'confirmDeletingAccount',
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

  /// `Contact information validated`
  String get contactInformationValidated {
    return Intl.message(
      'Contact information validated',
      name: 'contactInformationValidated',
      desc: '',
      args: [],
    );
  }

  /// `Contact methods`
  String get contactMethods {
    return Intl.message(
      'Contact methods',
      name: 'contactMethods',
      desc: '',
      args: [],
    );
  }

  /// `Contact method`
  String get contactMethod {
    return Intl.message(
      'Contact method',
      name: 'contactMethod',
      desc: '',
      args: [],
    );
  }

  /// `Content not found`
  String get contentNotFound {
    return Intl.message(
      'Content not found',
      name: 'contentNotFound',
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

  /// `Date Range`
  String get dateRange {
    return Intl.message('Date Range', name: 'dateRange', desc: '', args: []);
  }

  /// `The user account is removed immediately. This action cannot be undone.`
  String get deletingAccountCannotUndone {
    return Intl.message(
      'The user account is removed immediately. This action cannot be undone.',
      name: 'deletingAccountCannotUndone',
      desc: '',
      args: [],
    );
  }

  /// `Delete your account`
  String get deleteYourAccount {
    return Intl.message(
      'Delete your account',
      name: 'deleteYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get deleteAccount {
    return Intl.message(
      'Delete account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete account`
  String get deletingAccountFailed {
    return Intl.message(
      'Failed to delete account',
      name: 'deletingAccountFailed',
      desc: '',
      args: [],
    );
  }

  /// `Discover`
  String get discover {
    return Intl.message('Discover', name: 'discover', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
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
    return Intl.message('Environment', name: 'environment', desc: '', args: []);
  }

  /// `Event Log`
  String get eventLog {
    return Intl.message('Event Log', name: 'eventLog', desc: '', args: []);
  }

  /// `This project has been funded with support from the European Commission.\nThis publication reflects the views only of the author, and the Commission cannot be held responsible for any use which may be EN made of the information contained therein.`
  String get erasmusDisclaimer {
    return Intl.message(
      'This project has been funded with support from the European Commission.\nThis publication reflects the views only of the author, and the Commission cannot be held responsible for any use which may be EN made of the information contained therein.',
      name: 'erasmusDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
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

  /// `Feedback`
  String get feedback {
    return Intl.message('Feedback', name: 'feedback', desc: '', args: []);
  }

  /// `Feedback sent`
  String get feedbackSent {
    return Intl.message(
      'Feedback sent',
      name: 'feedbackSent',
      desc: '',
      args: [],
    );
  }

  /// `First name`
  String get firstName {
    return Intl.message('First name', name: 'firstName', desc: '', args: []);
  }

  /// `This field is obligatory`
  String get fieldCannotBeEmpty {
    return Intl.message(
      'This field is obligatory',
      name: 'fieldCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Flash On`
  String get flashOn {
    return Intl.message('Flash On', name: 'flashOn', desc: '', args: []);
  }

  /// `Flash Off`
  String get flashOff {
    return Intl.message('Flash Off', name: 'flashOff', desc: '', args: []);
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

  /// `Forms`
  String get forms {
    return Intl.message('Forms', name: 'forms', desc: '', args: []);
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
    return Intl.message('Get code', name: 'getCode', desc: '', args: []);
  }

  /// `Great!`
  String get great {
    return Intl.message('Great!', name: 'great', desc: '', args: []);
  }

  /// `Group code`
  String get groupCode {
    return Intl.message('Group code', name: 'groupCode', desc: '', args: []);
  }

  /// `Guardian Information`
  String get guardianInfo {
    return Intl.message(
      'Guardian Information',
      name: 'guardianInfo',
      desc: '',
      args: [],
    );
  }

  /// `Guardian phone`
  String get guardianPhone {
    return Intl.message(
      'Guardian phone',
      name: 'guardianPhone',
      desc: '',
      args: [],
    );
  }

  /// `Guardian name`
  String get guardianName {
    return Intl.message(
      'Guardian name',
      name: 'guardianName',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Last name`
  String get lastName {
    return Intl.message('Last name', name: 'lastName', desc: '', args: []);
  }

  /// `Loading`
  String get loading {
    return Intl.message('Loading', name: 'loading', desc: '', args: []);
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

  /// `Location retrieved`
  String get locationRetrieved {
    return Intl.message(
      'Location retrieved',
      name: 'locationRetrieved',
      desc: '',
      args: [],
    );
  }

  /// `Locations`
  String get locations {
    return Intl.message('Locations', name: 'locations', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
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

  /// `Event log is empty`
  String get logIsEmpty {
    return Intl.message(
      'Event log is empty',
      name: 'logIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
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
    return Intl.message('My Card', name: 'myCard', desc: '', args: []);
  }

  /// `Network error`
  String get networkError {
    return Intl.message(
      'Network error',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `Could not find any activities`
  String get noActivitiesFound {
    return Intl.message(
      'Could not find any activities',
      name: 'noActivitiesFound',
      desc: '',
      args: [],
    );
  }

  /// `No active benefits`
  String get noActiveBenefits {
    return Intl.message(
      'No active benefits',
      name: 'noActiveBenefits',
      desc: '',
      args: [],
    );
  }

  /// `No contact methods found`
  String get noContactMethodsFound {
    return Intl.message(
      'No contact methods found',
      name: 'noContactMethodsFound',
      desc: '',
      args: [],
    );
  }

  /// `No forms found`
  String get noFormsFound {
    return Intl.message(
      'No forms found',
      name: 'noFormsFound',
      desc: '',
      args: [],
    );
  }

  /// `Not verified`
  String get notVerified {
    return Intl.message(
      'Not verified',
      name: 'notVerified',
      desc: '',
      args: [],
    );
  }

  /// `No visits today`
  String get noVisitsToday {
    return Intl.message(
      'No visits today',
      name: 'noVisitsToday',
      desc: '',
      args: [],
    );
  }

  /// `No visits found`
  String get noVisitsFound {
    return Intl.message(
      'No visits found',
      name: 'noVisitsFound',
      desc: '',
      args: [],
    );
  }

  /// `No users found`
  String get noUsersFound {
    return Intl.message(
      'No users found',
      name: 'noUsersFound',
      desc: '',
      args: [],
    );
  }

  /// `No thank you`
  String get noThankYou {
    return Intl.message('No thank you', name: 'noThankYou', desc: '', args: []);
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `Yes`
  String get optionTrue {
    return Intl.message('Yes', name: 'optionTrue', desc: '', args: []);
  }

  /// `No`
  String get optionFalse {
    return Intl.message('No', name: 'optionFalse', desc: '', args: []);
  }

  /// `Page`
  String get pageContent {
    return Intl.message('Page', name: 'pageContent', desc: '', args: []);
  }

  /// `Page is empty`
  String get pageIsEmpty {
    return Intl.message(
      'Page is empty',
      name: 'pageIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Participants`
  String get participants {
    return Intl.message(
      'Participants',
      name: 'participants',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
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

  /// `Passwords don't match`
  String get passwordsDontMatch {
    return Intl.message(
      'Passwords don\'t match',
      name: 'passwordsDontMatch',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message('Pause', name: 'pause', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
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

  /// `Please enable camera for scanning QR codes`
  String get pleaseEnableCamera {
    return Intl.message(
      'Please enable camera for scanning QR codes',
      name: 'pleaseEnableCamera',
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

  /// `Please provide a valid email address`
  String get pleaseProvideValidEmail {
    return Intl.message(
      'Please provide a valid email address',
      name: 'pleaseProvideValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your name`
  String get pleaseProvideYourName {
    return Intl.message(
      'Please provide your name',
      name: 'pleaseProvideYourName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter phone number`
  String get pleaseEnterPhonenumber {
    return Intl.message(
      'Please enter phone number',
      name: 'pleaseEnterPhonenumber',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid phone number`
  String get pleaseProvideValidPhonenumber {
    return Intl.message(
      'Please provide a valid phone number',
      name: 'pleaseProvideValidPhonenumber',
      desc: '',
      args: [],
    );
  }

  /// `Postcode`
  String get postcode {
    return Intl.message('Postcode', name: 'postcode', desc: '', args: []);
  }

  /// `Previous`
  String get previous {
    return Intl.message('Previous', name: 'previous', desc: '', args: []);
  }

  /// `Privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get processing {
    return Intl.message('Processing', name: 'processing', desc: '', args: []);
  }

  /// `QR Scanner`
  String get qrScanner {
    return Intl.message('QR Scanner', name: 'qrScanner', desc: '', args: []);
  }

  /// `Read more`
  String get readMore {
    return Intl.message('Read more', name: 'readMore', desc: '', args: []);
  }

  /// `Rear Camera`
  String get rearCamera {
    return Intl.message('Rear Camera', name: 'rearCamera', desc: '', args: []);
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
    return Intl.message('Resume', name: 'resume', desc: '', args: []);
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

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Save answer`
  String get saveAnswer {
    return Intl.message('Save answer', name: 'saveAnswer', desc: '', args: []);
  }

  /// `Saving data failed`
  String get savingDataFailed {
    return Intl.message(
      'Saving data failed',
      name: 'savingDataFailed',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Account`
  String get settingsAccount {
    return Intl.message('Account', name: 'settingsAccount', desc: '', args: []);
  }

  /// `Common`
  String get settingsCommon {
    return Intl.message('Common', name: 'settingsCommon', desc: '', args: []);
  }

  /// `Misc`
  String get settingsMisc {
    return Intl.message('Misc', name: 'settingsMisc', desc: '', args: []);
  }

  /// `Welcome screen`
  String get showWelcomeScreen {
    return Intl.message(
      'Welcome screen',
      name: 'showWelcomeScreen',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Error`
  String get statusError {
    return Intl.message('Error', name: 'statusError', desc: '', args: []);
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

  /// `Thank you for your input!`
  String get thankyouForFeedback {
    return Intl.message(
      'Thank you for your input!',
      name: 'thankyouForFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
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
    return Intl.message('Unnamed', name: 'unnamed', desc: '', args: []);
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

  /// `User information`
  String get userInformation {
    return Intl.message(
      'User information',
      name: 'userInformation',
      desc: '',
      args: [],
    );
  }

  /// `User information updated`
  String get userInformationUpdated {
    return Intl.message(
      'User information updated',
      name: 'userInformationUpdated',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get userNotFound {
    return Intl.message(
      'User not found',
      name: 'userNotFound',
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

  /// `This field is required`
  String get valueIsRequired {
    return Intl.message(
      'This field is required',
      name: 'valueIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get valueYes {
    return Intl.message('Yes', name: 'valueYes', desc: '', args: []);
  }

  /// `No`
  String get valueNo {
    return Intl.message('No', name: 'valueNo', desc: '', args: []);
  }

  /// `Verified`
  String get verified {
    return Intl.message('Verified', name: 'verified', desc: '', args: []);
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `Visit recorded`
  String get visitRecorded {
    return Intl.message(
      'Visit recorded',
      name: 'visitRecorded',
      desc: '',
      args: [],
    );
  }

  /// `Visits`
  String get visits {
    return Intl.message('Visits', name: 'visits', desc: '', args: []);
  }

  /// `Visit added`
  String get visitAdded {
    return Intl.message('Visit added', name: 'visitAdded', desc: '', args: []);
  }

  /// `Visit removed`
  String get visitRemoved {
    return Intl.message(
      'Visit removed',
      name: 'visitRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Write your answer here`
  String get writeAnswerHere {
    return Intl.message(
      'Write your answer here',
      name: 'writeAnswerHere',
      desc: '',
      args: [],
    );
  }

  /// `You have to accept saving information to create account`
  String get youHaveToAgreeToSavingUserInformation {
    return Intl.message(
      'You have to accept saving information to create account',
      name: 'youHaveToAgreeToSavingUserInformation',
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
      Locale.fromSubtags(languageCode: 'pl'),
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
