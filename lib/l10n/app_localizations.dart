import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('fi'),
    Locale('hr'),
    Locale('pl'),
    Locale('pt')
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreated;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'User account deleted'**
  String get accountDeleted;

  /// No description provided for @accountCreationAccepted.
  ///
  /// In en, this message translates to:
  /// **'I acknowledge and accept that my information is saved to the database of the Sivulla application'**
  String get accountCreationAccepted;

  /// No description provided for @accountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion'**
  String get accountDeletion;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @activityCalendar.
  ///
  /// In en, this message translates to:
  /// **'Activity calendar'**
  String get activityCalendar;

  /// No description provided for @activityRegistrationSaved.
  ///
  /// In en, this message translates to:
  /// **'Registration saved'**
  String get activityRegistrationSaved;

  /// No description provided for @activityRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registering for activity failed'**
  String get activityRegistrationFailed;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @ageOver18.
  ///
  /// In en, this message translates to:
  /// **'Are you 18+ years old?'**
  String get ageOver18;

  /// No description provided for @agreeOnSavingInfo.
  ///
  /// In en, this message translates to:
  /// **'I agree on saving my information'**
  String get agreeOnSavingInfo;

  /// No description provided for @answerSaved.
  ///
  /// In en, this message translates to:
  /// **'Answer saved'**
  String get answerSaved;

  /// No description provided for @authenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating ... Please wait'**
  String get authenticating;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @btnContinueWithoutLogin.
  ///
  /// In en, this message translates to:
  /// **'Skip login'**
  String get btnContinueWithoutLogin;

  /// No description provided for @btnDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Dashboard'**
  String get btnDashboard;

  /// No description provided for @btnEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btnEdit;

  /// No description provided for @btnLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get btnLogin;

  /// No description provided for @btnReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get btnReturn;

  /// No description provided for @btnSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get btnSend;

  /// No description provided for @btnSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get btnSetNewPassword;

  /// No description provided for @btnUseEmail.
  ///
  /// In en, this message translates to:
  /// **'Use Email'**
  String get btnUseEmail;

  /// No description provided for @btnUsePhone.
  ///
  /// In en, this message translates to:
  /// **'Use Phone number'**
  String get btnUsePhone;

  /// No description provided for @btnValidateContact.
  ///
  /// In en, this message translates to:
  /// **'Validate contact information now'**
  String get btnValidateContact;

  /// No description provided for @btnValidateContactLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get btnValidateContactLater;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available'**
  String get cameraNotAvailable;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get choose;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @codeScanned.
  ///
  /// In en, this message translates to:
  /// **'Code scanned'**
  String get codeScanned;

  /// No description provided for @confirmDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Confirm user account deletion'**
  String get confirmDeletingAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmationKey.
  ///
  /// In en, this message translates to:
  /// **'Confirmation key'**
  String get confirmationKey;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInformation;

  /// No description provided for @contactInformationValidated.
  ///
  /// In en, this message translates to:
  /// **'Contact information validated'**
  String get contactInformationValidated;

  /// No description provided for @contactMethods.
  ///
  /// In en, this message translates to:
  /// **'Contact methods'**
  String get contactMethods;

  /// No description provided for @contactMethod.
  ///
  /// In en, this message translates to:
  /// **'Contact method'**
  String get contactMethod;

  /// No description provided for @contentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Content not found'**
  String get contentNotFound;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @deletingAccountCannotUndone.
  ///
  /// In en, this message translates to:
  /// **'The user account is removed immediately. This action cannot be undone.'**
  String get deletingAccountCannotUndone;

  /// No description provided for @deleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete your account'**
  String get deleteYourAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deletingAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get deletingAccountFailed;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailOrPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone number'**
  String get emailOrPhoneNumber;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @eventLog.
  ///
  /// In en, this message translates to:
  /// **'Event Log'**
  String get eventLog;

  /// No description provided for @erasmusDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This project has been funded with support from the European Commission.\nThis publication reflects the views only of the author, and the Commission cannot be held responsible for any use which may be EN made of the information contained therein.'**
  String get erasmusDisclaimer;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorsInForm.
  ///
  /// In en, this message translates to:
  /// **'Errors in form contents'**
  String get errorsInForm;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent'**
  String get feedbackSent;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @fieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This field is obligatory'**
  String get fieldCannotBeEmpty;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash On'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash Off'**
  String get flashOff;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get forms;

  /// No description provided for @frontCamera.
  ///
  /// In en, this message translates to:
  /// **'Front Camera'**
  String get frontCamera;

  /// No description provided for @getCode.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get getCode;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @groupCode.
  ///
  /// In en, this message translates to:
  /// **'Group code'**
  String get groupCode;

  /// No description provided for @guardianInfo.
  ///
  /// In en, this message translates to:
  /// **'Guardian Information'**
  String get guardianInfo;

  /// No description provided for @guardianPhone.
  ///
  /// In en, this message translates to:
  /// **'Guardian phone'**
  String get guardianPhone;

  /// No description provided for @guardianName.
  ///
  /// In en, this message translates to:
  /// **'Guardian name'**
  String get guardianName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @loadingBenefits.
  ///
  /// In en, this message translates to:
  /// **'Loading benefits'**
  String get loadingBenefits;

  /// No description provided for @locationRetrieved.
  ///
  /// In en, this message translates to:
  /// **'Location retrieved'**
  String get locationRetrieved;

  /// No description provided for @locations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locations;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @logIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Event log is empty'**
  String get logIsEmpty;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @moreInformation.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get moreInformation;

  /// No description provided for @myActivities.
  ///
  /// In en, this message translates to:
  /// **'My activities'**
  String get myActivities;

  /// No description provided for @myCard.
  ///
  /// In en, this message translates to:
  /// **'My Card'**
  String get myCard;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @noActivitiesFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find any activities'**
  String get noActivitiesFound;

  /// No description provided for @noActiveBenefits.
  ///
  /// In en, this message translates to:
  /// **'No active benefits'**
  String get noActiveBenefits;

  /// No description provided for @noContactMethodsFound.
  ///
  /// In en, this message translates to:
  /// **'No contact methods found'**
  String get noContactMethodsFound;

  /// No description provided for @noFormsFound.
  ///
  /// In en, this message translates to:
  /// **'No forms found'**
  String get noFormsFound;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @noVisitsToday.
  ///
  /// In en, this message translates to:
  /// **'No visits today'**
  String get noVisitsToday;

  /// No description provided for @noVisitsFound.
  ///
  /// In en, this message translates to:
  /// **'No visits found'**
  String get noVisitsFound;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @noThankYou.
  ///
  /// In en, this message translates to:
  /// **'No thank you'**
  String get noThankYou;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @optionTrue.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get optionTrue;

  /// No description provided for @optionFalse.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get optionFalse;

  /// No description provided for @pageContent.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pageContent;

  /// No description provided for @pageIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Page is empty'**
  String get pageIsEmpty;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Phone or Email'**
  String get phoneOrEmail;

  /// No description provided for @pleaseCompleteFormProperly.
  ///
  /// In en, this message translates to:
  /// **'Please complete the form properly'**
  String get pleaseCompleteFormProperly;

  /// No description provided for @pleaseEnableCamera.
  ///
  /// In en, this message translates to:
  /// **'Please enable camera for scanning QR codes'**
  String get pleaseEnableCamera;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterConfirmationKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirmation key'**
  String get pleaseEnterConfirmationKey;

  /// No description provided for @pleaseWaitRegistering.
  ///
  /// In en, this message translates to:
  /// **'Registering account, please wait'**
  String get pleaseWaitRegistering;

  /// No description provided for @pleaseProvideValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid email address'**
  String get pleaseProvideValidEmail;

  /// No description provided for @pleaseProvideYourName.
  ///
  /// In en, this message translates to:
  /// **'Please provide your name'**
  String get pleaseProvideYourName;

  /// No description provided for @pleaseEnterPhonenumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhonenumber;

  /// No description provided for @pleaseProvideValidPhonenumber.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid phone number'**
  String get pleaseProvideValidPhonenumber;

  /// No description provided for @postcode.
  ///
  /// In en, this message translates to:
  /// **'Postcode'**
  String get postcode;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @qrScanner.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get qrScanner;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @rearCamera.
  ///
  /// In en, this message translates to:
  /// **'Rear Camera'**
  String get rearCamera;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get requestFailed;

  /// No description provided for @requestNewCode.
  ///
  /// In en, this message translates to:
  /// **'Get new code'**
  String get requestNewCode;

  /// No description provided for @requestNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Get new Password'**
  String get requestNewPasswordTitle;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retrievingCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Retrieving coordinates'**
  String get retrievingCoordinates;

  /// No description provided for @readyToScan.
  ///
  /// In en, this message translates to:
  /// **'Scanner ready'**
  String get readyToScan;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAnswer.
  ///
  /// In en, this message translates to:
  /// **'Save answer'**
  String get saveAnswer;

  /// No description provided for @savingDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Saving data failed'**
  String get savingDataFailed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get settingsCommon;

  /// No description provided for @settingsMisc.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get settingsMisc;

  /// No description provided for @showWelcomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Welcome screen'**
  String get showWelcomeScreen;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @thankyouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your input!'**
  String get thankyouForFeedback;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @unnamedActivity.
  ///
  /// In en, this message translates to:
  /// **'Unnamed activity'**
  String get unnamedActivity;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamed;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'unknown user'**
  String get unknownUser;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User information'**
  String get userInformation;

  /// No description provided for @userInformationUpdated.
  ///
  /// In en, this message translates to:
  /// **'User information updated'**
  String get userInformationUpdated;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @validateContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Validate contact information'**
  String get validateContactTitle;

  /// No description provided for @valueIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get valueIsRequired;

  /// No description provided for @valueYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get valueYes;

  /// No description provided for @valueNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get valueNo;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @visitRecorded.
  ///
  /// In en, this message translates to:
  /// **'Visit recorded'**
  String get visitRecorded;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get visits;

  /// No description provided for @visitAdded.
  ///
  /// In en, this message translates to:
  /// **'Visit added'**
  String get visitAdded;

  /// No description provided for @visitRemoved.
  ///
  /// In en, this message translates to:
  /// **'Visit removed'**
  String get visitRemoved;

  /// No description provided for @writeAnswerHere.
  ///
  /// In en, this message translates to:
  /// **'Write your answer here'**
  String get writeAnswerHere;

  /// No description provided for @youHaveToAgreeToSavingUserInformation.
  ///
  /// In en, this message translates to:
  /// **'You have to accept saving information to create account'**
  String get youHaveToAgreeToSavingUserInformation;

  /// No description provided for @youthcardLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Youth Card Login'**
  String get youthcardLoginTitle;

  /// No description provided for @youthcardDashboard.
  ///
  /// In en, this message translates to:
  /// **'Youth Card'**
  String get youthcardDashboard;

  /// No description provided for @youthcardSettings.
  ///
  /// In en, this message translates to:
  /// **'Youth Card Settings'**
  String get youthcardSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'cs',
        'de',
        'en',
        'fi',
        'hr',
        'pl',
        'pt'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fi':
      return AppLocalizationsFi();
    case 'hr':
      return AppLocalizationsHr();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
