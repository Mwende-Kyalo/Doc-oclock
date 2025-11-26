import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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
    Locale('en'),
    Locale('sw')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Doc O\'Clock'**
  String get appTitle;

  /// No description provided for @welcomeToApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Telemedicine App'**
  String get welcomeToApp;

  /// No description provided for @signInAsPatient.
  ///
  /// In en, this message translates to:
  /// **'Sign in as Patient'**
  String get signInAsPatient;

  /// No description provided for @signUpAsPatient.
  ///
  /// In en, this message translates to:
  /// **'Sign up as Patient'**
  String get signUpAsPatient;

  /// No description provided for @signInAsDoctor.
  ///
  /// In en, this message translates to:
  /// **'Sign in as Doctor'**
  String get signInAsDoctor;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @usabilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Usability Settings'**
  String get usabilitySettings;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @viewEhr.
  ///
  /// In en, this message translates to:
  /// **'View EHR'**
  String get viewEhr;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @medicineInfo.
  ///
  /// In en, this message translates to:
  /// **'Medicine Info'**
  String get medicineInfo;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @makePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get makePayment;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @doctorSignIn.
  ///
  /// In en, this message translates to:
  /// **'Doctor Sign In'**
  String get doctorSignIn;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @doctorAppointments.
  ///
  /// In en, this message translates to:
  /// **'View Appointments'**
  String get doctorAppointments;

  /// No description provided for @doctorEhr.
  ///
  /// In en, this message translates to:
  /// **'View EHR'**
  String get doctorEhr;

  /// No description provided for @doctorPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get doctorPayments;

  /// No description provided for @doctorHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get doctorHistory;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient Details'**
  String get patientDetails;

  /// No description provided for @addEhr.
  ///
  /// In en, this message translates to:
  /// **'Add EHR'**
  String get addEhr;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccount;

  /// No description provided for @areYouADoctor.
  ///
  /// In en, this message translates to:
  /// **'Are you a doctor? Sign in here'**
  String get areYouADoctor;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noAvailability.
  ///
  /// In en, this message translates to:
  /// **'No availability at the moment'**
  String get noAvailability;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @consultationType.
  ///
  /// In en, this message translates to:
  /// **'Consultation Type'**
  String get consultationType;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @confirmAppointment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Appointment'**
  String get confirmAppointment;

  /// No description provided for @paymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get paymentOptions;

  /// No description provided for @payLater.
  ///
  /// In en, this message translates to:
  /// **'Pay Later'**
  String get payLater;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @mpesa.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa'**
  String get mpesa;

  /// No description provided for @payViaMpesa.
  ///
  /// In en, this message translates to:
  /// **'Pay via M-Pesa mobile money'**
  String get payViaMpesa;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @payViaCard.
  ///
  /// In en, this message translates to:
  /// **'Pay via debit/credit card'**
  String get payViaCard;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments have been made yet'**
  String get noPaymentsYet;

  /// No description provided for @backToAppointments.
  ///
  /// In en, this message translates to:
  /// **'Back to Appointments'**
  String get backToAppointments;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessful;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhone;

  /// No description provided for @pleaseFillCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Please fill all card details'**
  String get pleaseFillCardDetails;

  /// No description provided for @fetchingInfo.
  ///
  /// In en, this message translates to:
  /// **'Fetching medicine information...'**
  String get fetchingInfo;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @enterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Enter a medicine name to get detailed information'**
  String get enterMedicineName;

  /// No description provided for @includingSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Including side effects, contraindications, and special instructions'**
  String get includingSideEffects;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @getMedicineInfo.
  ///
  /// In en, this message translates to:
  /// **'Get Medicine Info'**
  String get getMedicineInfo;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @pastAppointments.
  ///
  /// In en, this message translates to:
  /// **'Past Appointments'**
  String get pastAppointments;

  /// No description provided for @pastCalls.
  ///
  /// In en, this message translates to:
  /// **'Past Calls'**
  String get pastCalls;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointments;

  /// No description provided for @noCalls.
  ///
  /// In en, this message translates to:
  /// **'No calls found'**
  String get noCalls;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @rescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get rescheduled;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Doctor Name'**
  String get doctorName;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @availableSlots.
  ///
  /// In en, this message translates to:
  /// **'Available Slots'**
  String get availableSlots;

  /// No description provided for @bookAppointments.
  ///
  /// In en, this message translates to:
  /// **'Book Appointments'**
  String get bookAppointments;

  /// No description provided for @orderPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Order Prescriptions'**
  String get orderPrescriptions;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @patientEhrs.
  ///
  /// In en, this message translates to:
  /// **'Patient EHRs'**
  String get patientEhrs;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get signInFailed;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed'**
  String get signUpFailed;

  /// No description provided for @donthaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get donthaveAccount;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordMustBeAtLeast6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note: Doctors can only sign in with provided credentials.'**
  String get note;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection to Supabase'**
  String get testConnection;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get bookingFailed;

  /// No description provided for @availableDatesTimes.
  ///
  /// In en, this message translates to:
  /// **'Available Dates & Times'**
  String get availableDatesTimes;

  /// No description provided for @bookAppointmentWith.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment with'**
  String get bookAppointmentWith;

  /// No description provided for @pleaseConfirmDetails.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your appointment details:'**
  String get pleaseConfirmDetails;

  /// No description provided for @appointmentBookedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been booked successfully! Would you like to pay now or pay later?'**
  String get appointmentBookedSuccessfully;

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get videoCall;

  /// No description provided for @voiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice Call'**
  String get voiceCall;

  /// No description provided for @consultationFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation Fee'**
  String get consultationFee;

  /// No description provided for @searchMedicineInformation.
  ///
  /// In en, this message translates to:
  /// **'Search Medicine Information'**
  String get searchMedicineInformation;

  /// No description provided for @enterMedicineNames.
  ///
  /// In en, this message translates to:
  /// **'Enter medicine name(s)'**
  String get enterMedicineNames;

  /// No description provided for @medicineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Paracetamol, Aspirin, Ibuprofen'**
  String get medicineNameHint;

  /// No description provided for @generalInformation.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInformation;

  /// No description provided for @sideEffects.
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get sideEffects;

  /// No description provided for @contraindications.
  ///
  /// In en, this message translates to:
  /// **'Contraindications (When NOT to Take)'**
  String get contraindications;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get noReviews;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @rateDoctor.
  ///
  /// In en, this message translates to:
  /// **'Rate Doctor'**
  String get rateDoctor;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @reviewText.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewText;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get thankYou;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your review has been submitted successfully'**
  String get reviewSubmitted;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'Total Reviews'**
  String get totalReviews;

  /// No description provided for @patientReviews.
  ///
  /// In en, this message translates to:
  /// **'Patient Reviews'**
  String get patientReviews;

  /// No description provided for @viewAllReviews.
  ///
  /// In en, this message translates to:
  /// **'View All Reviews'**
  String get viewAllReviews;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReview;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete Review'**
  String get deleteReview;

  /// No description provided for @areYouSureDeleteReview.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get areYouSureDeleteReview;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted successfully'**
  String get reviewDeleted;

  /// No description provided for @updateReview.
  ///
  /// In en, this message translates to:
  /// **'Update Review'**
  String get updateReview;

  /// No description provided for @reviewUpdated.
  ///
  /// In en, this message translates to:
  /// **'Review updated successfully'**
  String get reviewUpdated;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @pleaseWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Please write a review'**
  String get pleaseWriteReview;

  /// No description provided for @reviewTextPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this doctor...'**
  String get reviewTextPlaceholder;

  /// No description provided for @rateService.
  ///
  /// In en, this message translates to:
  /// **'Rate Service'**
  String get rateService;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @verifiedPatient.
  ///
  /// In en, this message translates to:
  /// **'Verified Patient'**
  String get verifiedPatient;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @noPaymentsMadeYet.
  ///
  /// In en, this message translates to:
  /// **'No payments have been made yet'**
  String get noPaymentsMadeYet;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @paymentAlreadyMade.
  ///
  /// In en, this message translates to:
  /// **'Payment Already Made'**
  String get paymentAlreadyMade;

  /// No description provided for @thisAppointmentPaid.
  ///
  /// In en, this message translates to:
  /// **'This appointment has already been paid for.'**
  String get thisAppointmentPaid;

  /// No description provided for @noUnpaidAppointments.
  ///
  /// In en, this message translates to:
  /// **'No Unpaid Appointments'**
  String get noUnpaidAppointments;

  /// No description provided for @allAppointmentsPaid.
  ///
  /// In en, this message translates to:
  /// **'All your appointments have been paid for.'**
  String get allAppointmentsPaid;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get appointmentDetails;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get cardPayment;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @notPaid.
  ///
  /// In en, this message translates to:
  /// **'Not Paid'**
  String get notPaid;

  /// No description provided for @medicineInformation.
  ///
  /// In en, this message translates to:
  /// **'Medicine Information'**
  String get medicineInformation;

  /// No description provided for @pleaseEnterAtLeastOneMedicine.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one medicine name'**
  String get pleaseEnterAtLeastOneMedicine;

  /// No description provided for @errorFetchingMedicineInfo.
  ///
  /// In en, this message translates to:
  /// **'Error fetching medicine information'**
  String get errorFetchingMedicineInfo;

  /// No description provided for @errorFetchingInformation.
  ///
  /// In en, this message translates to:
  /// **'Error fetching information'**
  String get errorFetchingInformation;

  /// No description provided for @unableToFetchInfo.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch information'**
  String get unableToFetchInfo;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with a doctor'**
  String get startConversation;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @initiateVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Initiate Video Call'**
  String get initiateVideoCall;

  /// No description provided for @initiateVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Initiate Voice Call'**
  String get initiateVoiceCall;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startChatting.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with your doctor'**
  String get startChatting;

  /// No description provided for @appointmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Appointment not found'**
  String get appointmentNotFound;

  /// No description provided for @noPastAppointments.
  ///
  /// In en, this message translates to:
  /// **'No past appointments found'**
  String get noPastAppointments;

  /// No description provided for @noPastCalls.
  ///
  /// In en, this message translates to:
  /// **'No past calls found'**
  String get noPastCalls;

  /// No description provided for @pastAppointmentsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your past appointments will appear here'**
  String get pastAppointmentsWillAppearHere;

  /// No description provided for @pastCallsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your past video and voice calls will appear here'**
  String get pastCallsWillAppearHere;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @consultationMethod.
  ///
  /// In en, this message translates to:
  /// **'Consultation Method'**
  String get consultationMethod;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @startVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Start Video Call'**
  String get startVideoCall;

  /// No description provided for @viewPatientHistory.
  ///
  /// In en, this message translates to:
  /// **'View Patient History (EHR)'**
  String get viewPatientHistory;

  /// No description provided for @editAppointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment Details'**
  String get editAppointmentDetails;

  /// No description provided for @paymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Payment is required before you can attend the consultation.'**
  String get paymentRequired;

  /// No description provided for @mpesaPayment.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa Payment'**
  String get mpesaPayment;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @mpesaPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa Phone Number'**
  String get mpesaPhoneNumber;

  /// No description provided for @youWillReceiveMpesaPrompt.
  ///
  /// In en, this message translates to:
  /// **'You will receive an M-Pesa prompt to enter your PIN.'**
  String get youWillReceiveMpesaPrompt;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expiry;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolderName;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get processingPayment;

  /// No description provided for @pleaseCheckPhoneForMpesa.
  ///
  /// In en, this message translates to:
  /// **'Please check your phone for M-Pesa prompt'**
  String get pleaseCheckPhoneForMpesa;

  /// No description provided for @paymentRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment request failed'**
  String get paymentRequestFailed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @yourPaymentHistoryWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your payment history will appear here'**
  String get yourPaymentHistoryWillAppear;

  /// No description provided for @payConsultationFee.
  ///
  /// In en, this message translates to:
  /// **'Pay Consultation Fee'**
  String get payConsultationFee;

  /// No description provided for @youWillReceivePrompt.
  ///
  /// In en, this message translates to:
  /// **'You will receive an M-Pesa prompt to enter your PIN.'**
  String get youWillReceivePrompt;

  /// No description provided for @searchingMedicineInfo.
  ///
  /// In en, this message translates to:
  /// **'Searching medicine information...'**
  String get searchingMedicineInfo;

  /// No description provided for @loadingMedicineInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading medicine information...'**
  String get loadingMedicineInfo;

  /// No description provided for @enterMedicineNameForInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter a medicine name to get detailed information'**
  String get enterMedicineNameForInfo;

  /// No description provided for @errorFetchingInfo.
  ///
  /// In en, this message translates to:
  /// **'Error fetching information'**
  String get errorFetchingInfo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @emptyStateNoMedicines.
  ///
  /// In en, this message translates to:
  /// **'Enter a medicine name to get detailed information'**
  String get emptyStateNoMedicines;

  /// No description provided for @emptyStateMedicinesSubtext.
  ///
  /// In en, this message translates to:
  /// **'Including side effects, contraindications, and special instructions'**
  String get emptyStateMedicinesSubtext;

  /// No description provided for @startConversationWithDoctor.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with a doctor'**
  String get startConversationWithDoctor;

  /// No description provided for @startChattingWithDoctor.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with your doctor'**
  String get startChattingWithDoctor;

  /// No description provided for @chatWithDoctor.
  ///
  /// In en, this message translates to:
  /// **'Chat with Doctor'**
  String get chatWithDoctor;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online Status'**
  String get onlineStatus;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last Seen'**
  String get lastSeen;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @readReceipt.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readReceipt;

  /// No description provided for @deliveredReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredReceipt;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// No description provided for @messageFailed.
  ///
  /// In en, this message translates to:
  /// **'Message failed to send'**
  String get messageFailed;

  /// No description provided for @videoCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get videoCallTitle;

  /// No description provided for @voiceCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Call'**
  String get voiceCallTitle;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @turnCameraOn.
  ///
  /// In en, this message translates to:
  /// **'Turn Camera On'**
  String get turnCameraOn;

  /// No description provided for @turnCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Turn Camera Off'**
  String get turnCameraOff;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch Camera'**
  String get switchCamera;

  /// No description provided for @callConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get callConnecting;

  /// No description provided for @callRinging.
  ///
  /// In en, this message translates to:
  /// **'Ringing...'**
  String get callRinging;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call Ended'**
  String get callEnded;

  /// No description provided for @callDuration.
  ///
  /// In en, this message translates to:
  /// **'Call Duration'**
  String get callDuration;

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Call Failed'**
  String get callFailed;

  /// No description provided for @addAvailability.
  ///
  /// In en, this message translates to:
  /// **'Add Availability'**
  String get addAvailability;

  /// No description provided for @removeAvailability.
  ///
  /// In en, this message translates to:
  /// **'Remove Availability'**
  String get removeAvailability;

  /// No description provided for @availableDates.
  ///
  /// In en, this message translates to:
  /// **'Available Dates'**
  String get availableDates;

  /// No description provided for @addDate.
  ///
  /// In en, this message translates to:
  /// **'Add Date'**
  String get addDate;

  /// No description provided for @selectAvailabilityDate.
  ///
  /// In en, this message translates to:
  /// **'Select Availability Date'**
  String get selectAvailabilityDate;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @availabilityAdded.
  ///
  /// In en, this message translates to:
  /// **'Availability added successfully'**
  String get availabilityAdded;

  /// No description provided for @availabilityRemoved.
  ///
  /// In en, this message translates to:
  /// **'Availability removed successfully'**
  String get availabilityRemoved;

  /// No description provided for @ehrRecords.
  ///
  /// In en, this message translates to:
  /// **'EHR Records'**
  String get ehrRecords;

  /// No description provided for @noEhrRecords.
  ///
  /// In en, this message translates to:
  /// **'No EHR records found'**
  String get noEhrRecords;

  /// No description provided for @addEhrRecord.
  ///
  /// In en, this message translates to:
  /// **'Add EHR Record'**
  String get addEhrRecord;

  /// No description provided for @editEhrRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit EHR Record'**
  String get editEhrRecord;

  /// No description provided for @diagnosisLabel.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosisLabel;

  /// No description provided for @prescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescriptionLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Record saved successfully'**
  String get recordSaved;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted successfully'**
  String get recordDeleted;

  /// No description provided for @failedToSaveRecord.
  ///
  /// In en, this message translates to:
  /// **'Failed to save record'**
  String get failedToSaveRecord;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @areYouSureDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get areYouSureDeleteRecord;

  /// No description provided for @addPrescription.
  ///
  /// In en, this message translates to:
  /// **'Add Prescription'**
  String get addPrescription;

  /// No description provided for @prescriptionMode.
  ///
  /// In en, this message translates to:
  /// **'Prescription Mode'**
  String get prescriptionMode;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @removeMedication.
  ///
  /// In en, this message translates to:
  /// **'Remove Medication'**
  String get removeMedication;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @patientEmail.
  ///
  /// In en, this message translates to:
  /// **'Patient Email'**
  String get patientEmail;

  /// No description provided for @patientPhone.
  ///
  /// In en, this message translates to:
  /// **'Patient Phone'**
  String get patientPhone;

  /// No description provided for @contactPatient.
  ///
  /// In en, this message translates to:
  /// **'Contact Patient'**
  String get contactPatient;

  /// No description provided for @viewEhrRecords.
  ///
  /// In en, this message translates to:
  /// **'View EHR Records'**
  String get viewEhrRecords;

  /// No description provided for @addNewEhrRecord.
  ///
  /// In en, this message translates to:
  /// **'Add New EHR Record'**
  String get addNewEhrRecord;

  /// No description provided for @appointmentDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get appointmentDateAndTime;

  /// No description provided for @viewAllAppointments.
  ///
  /// In en, this message translates to:
  /// **'View All Appointments'**
  String get viewAllAppointments;

  /// No description provided for @todayAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get todayAppointments;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @noTodayAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments today'**
  String get noTodayAppointments;

  /// No description provided for @acceptAppointment.
  ///
  /// In en, this message translates to:
  /// **'Accept Appointment'**
  String get acceptAppointment;

  /// No description provided for @rejectAppointment.
  ///
  /// In en, this message translates to:
  /// **'Reject Appointment'**
  String get rejectAppointment;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointment;

  /// No description provided for @appointmentAccepted.
  ///
  /// In en, this message translates to:
  /// **'Appointment accepted'**
  String get appointmentAccepted;

  /// No description provided for @appointmentRejected.
  ///
  /// In en, this message translates to:
  /// **'Appointment rejected'**
  String get appointmentRejected;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled'**
  String get appointmentCancelled;

  /// No description provided for @appointmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Appointment marked as completed'**
  String get appointmentCompleted;

  /// No description provided for @noAppointmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No appointments available'**
  String get noAppointmentsAvailable;

  /// No description provided for @doctorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Doctor Dashboard'**
  String get doctorDashboard;

  /// No description provided for @patientDashboard.
  ///
  /// In en, this message translates to:
  /// **'Patient Dashboard'**
  String get patientDashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @orderPrescription.
  ///
  /// In en, this message translates to:
  /// **'Order Prescription'**
  String get orderPrescription;

  /// No description provided for @viewPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'View Prescriptions'**
  String get viewPrescriptions;

  /// No description provided for @prescriptionOrdered.
  ///
  /// In en, this message translates to:
  /// **'Prescription ordered successfully'**
  String get prescriptionOrdered;

  /// No description provided for @prescriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Prescription Details'**
  String get prescriptionDetails;

  /// No description provided for @ordered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get ordered;

  /// No description provided for @notOrdered.
  ///
  /// In en, this message translates to:
  /// **'Not Ordered'**
  String get notOrdered;

  /// No description provided for @markAsOrdered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ordered'**
  String get markAsOrdered;

  /// No description provided for @prescriptionMarkedOrdered.
  ///
  /// In en, this message translates to:
  /// **'Prescription marked as ordered'**
  String get prescriptionMarkedOrdered;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you instructions to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email'**
  String get resetLinkSent;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterEmailForReset;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerificationTitle;

  /// No description provided for @enterOtpSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your email'**
  String get enterOtpSentToEmail;

  /// No description provided for @otpVerified.
  ///
  /// In en, this message translates to:
  /// **'OTP verified successfully'**
  String get otpVerified;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed'**
  String get otpVerificationFailed;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOtp;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in'**
  String get resendOtpIn;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @resendOtpNow.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP Now'**
  String get resendOtpNow;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @deleteAppointment.
  ///
  /// In en, this message translates to:
  /// **'Delete Appointment'**
  String get deleteAppointment;

  /// No description provided for @areYouSureDeleteAppointment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this appointment? This action cannot be undone.'**
  String get areYouSureDeleteAppointment;

  /// No description provided for @selectNewDate.
  ///
  /// In en, this message translates to:
  /// **'Select New Date'**
  String get selectNewDate;

  /// No description provided for @selectNewTime.
  ///
  /// In en, this message translates to:
  /// **'Select New Time'**
  String get selectNewTime;

  /// No description provided for @appointmentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Appointment deleted successfully'**
  String get appointmentDeleted;

  /// No description provided for @appointmentRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Appointment rescheduled successfully'**
  String get appointmentRescheduled;

  /// No description provided for @failedToDeleteAppointment.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete appointment'**
  String get failedToDeleteAppointment;

  /// No description provided for @failedToRescheduleAppointment.
  ///
  /// In en, this message translates to:
  /// **'Failed to reschedule appointment'**
  String get failedToRescheduleAppointment;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @myPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'My Prescriptions'**
  String get myPrescriptions;

  /// No description provided for @noPrescriptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No prescriptions found'**
  String get noPrescriptionsFound;

  /// No description provided for @prescriptionsFromDoctors.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions from doctors will appear here'**
  String get prescriptionsFromDoctors;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @medicalRecordsEhr.
  ///
  /// In en, this message translates to:
  /// **'Medical Records (EHR)'**
  String get medicalRecordsEhr;

  /// No description provided for @noMedicalRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No medical records found'**
  String get noMedicalRecordsFound;

  /// No description provided for @myAppointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointmentsTitle;

  /// No description provided for @appointmentType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get appointmentType;

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @yourAvailability.
  ///
  /// In en, this message translates to:
  /// **'Your Availability'**
  String get yourAvailability;

  /// No description provided for @noAvailabilityAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No availability added yet'**
  String get noAvailabilityAddedYet;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @pleaseSelectDateStartTimeEndTime.
  ///
  /// In en, this message translates to:
  /// **'Please select date, start time, and end time'**
  String get pleaseSelectDateStartTimeEndTime;

  /// No description provided for @endTimeMustBeAfterStartTime.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endTimeMustBeAfterStartTime;

  /// No description provided for @failedToLoadAvailabilities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load availabilities'**
  String get failedToLoadAvailabilities;

  /// No description provided for @availabilityDeleted.
  ///
  /// In en, this message translates to:
  /// **'Availability deleted'**
  String get availabilityDeleted;

  /// No description provided for @failedToDeleteAvailability.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete availability'**
  String get failedToDeleteAvailability;

  /// No description provided for @areYouSureDeleteAvailability.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this availability? This will not affect already booked appointments.'**
  String get areYouSureDeleteAvailability;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @updateRecord.
  ///
  /// In en, this message translates to:
  /// **'Update Record'**
  String get updateRecord;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get saveRecord;

  /// No description provided for @prescriptionSummary.
  ///
  /// In en, this message translates to:
  /// **'Prescription Summary'**
  String get prescriptionSummary;

  /// No description provided for @additionalPrescriptionNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional prescription notes'**
  String get additionalPrescriptionNotes;

  /// No description provided for @pleaseEnterDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Please enter diagnosis'**
  String get pleaseEnterDiagnosis;

  /// No description provided for @pleaseEnterPrescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter prescription'**
  String get pleaseEnterPrescription;

  /// No description provided for @pleaseAddAtLeastOneMedication.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one medication'**
  String get pleaseAddAtLeastOneMedication;

  /// No description provided for @pleaseFillAllMedicationFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all medication fields'**
  String get pleaseFillAllMedicationFields;

  /// No description provided for @recordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Record updated successfully! Changes will be visible to the patient.'**
  String get recordUpdatedSuccessfully;

  /// No description provided for @pleaseEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get pleaseEnterOtp;

  /// No description provided for @otpMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 digits'**
  String get otpMustBe6Digits;

  /// No description provided for @invalidOtpError.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOtpError;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset failed'**
  String get resetFailed;

  /// No description provided for @invalidDoctorCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid doctor credentials'**
  String get invalidDoctorCredentials;

  /// No description provided for @doctorAccountsCreatedByAdministrators.
  ///
  /// In en, this message translates to:
  /// **'Note: Doctor accounts are created by administrators'**
  String get doctorAccountsCreatedByAdministrators;

  /// No description provided for @areYouAPatientPatientSignIn.
  ///
  /// In en, this message translates to:
  /// **'Are you a patient? Patient sign in'**
  String get areYouAPatientPatientSignIn;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @videoOn.
  ///
  /// In en, this message translates to:
  /// **'Video On'**
  String get videoOn;

  /// No description provided for @videoOff.
  ///
  /// In en, this message translates to:
  /// **'Video Off'**
  String get videoOff;

  /// No description provided for @earpiece.
  ///
  /// In en, this message translates to:
  /// **'Earpiece'**
  String get earpiece;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @incomingCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get incomingCall;

  /// No description provided for @outgoingCall.
  ///
  /// In en, this message translates to:
  /// **'Outgoing call'**
  String get outgoingCall;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {user}!'**
  String welcomeUser(String user);

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecords;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication (2FA)'**
  String get twoFactorAuthentication;

  /// No description provided for @twoFactorEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled - Your account is protected with 2FA'**
  String get twoFactorEnabled;

  /// No description provided for @twoFactorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled - Add an extra layer of security'**
  String get twoFactorDisabled;

  /// No description provided for @enableTwoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Enable Two-Factor Authentication'**
  String get enableTwoFactorAuthentication;

  /// No description provided for @disableTwoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Disable Two-Factor Authentication'**
  String get disableTwoFactorAuthentication;

  /// No description provided for @twoFactorEnabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication enabled successfully'**
  String get twoFactorEnabledSuccessfully;

  /// No description provided for @twoFactorDisabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication disabled'**
  String get twoFactorDisabledSuccessfully;

  /// No description provided for @disable2FAConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable 2FA? This will make your account less secure.'**
  String get disable2FAConfirmation;

  /// No description provided for @enable2FAInstructions.
  ///
  /// In en, this message translates to:
  /// **'You will receive a verification code via email. Please enter the code to complete the setup.'**
  String get enable2FAInstructions;

  /// No description provided for @verifyEmailCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Email Code'**
  String get verifyEmailCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code sent to your email:'**
  String get enterVerificationCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @noPrescriptionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No prescriptions available'**
  String get noPrescriptionsAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
