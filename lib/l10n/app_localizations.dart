import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'My interventions'**
  String get title;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search intervention...'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No intervention found'**
  String get noData;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}'**
  String hello(Object name);

  /// No description provided for @newAlert.
  ///
  /// In en, this message translates to:
  /// **'New alert'**
  String get newAlert;

  /// No description provided for @newInterventionAdded.
  ///
  /// In en, this message translates to:
  /// **'New intervention added'**
  String get newInterventionAdded;

  /// No description provided for @locationCentered.
  ///
  /// In en, this message translates to:
  /// **'Location centered'**
  String get locationCentered;

  /// No description provided for @myInterventions.
  ///
  /// In en, this message translates to:
  /// **'My\ninterventions'**
  String get myInterventions;

  /// No description provided for @searchReclamation.
  ///
  /// In en, this message translates to:
  /// **'Search a complaint...'**
  String get searchReclamation;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get opened;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @noInterventionFound.
  ///
  /// In en, this message translates to:
  /// **'No intervention found'**
  String get noInterventionFound;

  /// No description provided for @noType.
  ///
  /// In en, this message translates to:
  /// **'No type'**
  String get noType;

  /// No description provided for @unknownClient.
  ///
  /// In en, this message translates to:
  /// **'Unknown client'**
  String get unknownClient;

  /// No description provided for @reclamationNumber.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get reclamationNumber;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientLabel;

  /// No description provided for @invalidInterventionId.
  ///
  /// In en, this message translates to:
  /// **'Invalid intervention ID'**
  String get invalidInterventionId;

  /// No description provided for @unprocessedDerangementsCount.
  ///
  /// In en, this message translates to:
  /// **'You have {count} unprocessed incidents'**
  String unprocessedDerangementsCount(int count);

  /// No description provided for @quickMenu.
  ///
  /// In en, this message translates to:
  /// **'Quick Menu'**
  String get quickMenu;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @mapDerangements.
  ///
  /// In en, this message translates to:
  /// **'Map\nissues'**
  String get mapDerangements;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'View\nalerts'**
  String get alerts;

  /// No description provided for @dailyStats.
  ///
  /// In en, this message translates to:
  /// **'Daily\nstats'**
  String get dailyStats;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @fullHistory.
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get fullHistory;

  /// No description provided for @finishedInterventions.
  ///
  /// In en, this message translates to:
  /// **'Finished interventions'**
  String get finishedInterventions;

  /// No description provided for @pendingTickets.
  ///
  /// In en, this message translates to:
  /// **'Pending tickets'**
  String get pendingTickets;

  /// No description provided for @slaRespected.
  ///
  /// In en, this message translates to:
  /// **'SLA respected'**
  String get slaRespected;

  /// No description provided for @averageTime.
  ///
  /// In en, this message translates to:
  /// **'Average time'**
  String get averageTime;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'coming soon'**
  String get comingSoon;

  /// No description provided for @generatingKpiReport.
  ///
  /// In en, this message translates to:
  /// **'Generating KPI report...'**
  String get generatingKpiReport;

  /// No description provided for @kpiReportGenerated.
  ///
  /// In en, this message translates to:
  /// **'KPI report generated successfully'**
  String get kpiReportGenerated;

  /// No description provided for @kpi.
  ///
  /// In en, this message translates to:
  /// **'KPI'**
  String get kpi;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @interventions.
  ///
  /// In en, this message translates to:
  /// **'interventions'**
  String get interventions;

  /// No description provided for @vacationMode.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode'**
  String get vacationMode;

  /// No description provided for @vacationActive.
  ///
  /// In en, this message translates to:
  /// **'You are currently on vacation'**
  String get vacationActive;

  /// No description provided for @vacationInactive.
  ///
  /// In en, this message translates to:
  /// **'You are available for work'**
  String get vacationInactive;

  /// No description provided for @vacationConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get vacationConfirmTitle;

  /// No description provided for @vacationConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to switch to vacation mode?'**
  String get vacationConfirmMessage;

  /// No description provided for @backConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Back to work'**
  String get backConfirmTitle;

  /// No description provided for @backConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to return to active mode?'**
  String get backConfirmMessage;

  /// No description provided for @happyVacation.
  ///
  /// In en, this message translates to:
  /// **'Happy vacation! We wish you a joyful vacation.'**
  String get happyVacation;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Glad to see you again.'**
  String get welcomeBack;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @itinerary.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get itinerary;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @problem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get problem;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @reclamation.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get reclamation;

  /// No description provided for @routeError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open route'**
  String get routeError;

  /// No description provided for @callError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open call'**
  String get callError;

  /// No description provided for @invalidId.
  ///
  /// In en, this message translates to:
  /// **'Invalid complaint ID'**
  String get invalidId;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Intervention started'**
  String get started;

  /// No description provided for @phoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number unavailable'**
  String get phoneUnavailable;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get serviceType;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @slaMissed.
  ///
  /// In en, this message translates to:
  /// **'SLA Missed'**
  String get slaMissed;

  /// No description provided for @slaSoon.
  ///
  /// In en, this message translates to:
  /// **'SLA Soon'**
  String get slaSoon;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @errorReport.
  ///
  /// In en, this message translates to:
  /// **'Error Report'**
  String get errorReport;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Algeria Telecom'**
  String get company;

  /// No description provided for @systemDate.
  ///
  /// In en, this message translates to:
  /// **'System date'**
  String get systemDate;

  /// No description provided for @problemReason.
  ///
  /// In en, this message translates to:
  /// **'Problem reason'**
  String get problemReason;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem...'**
  String get describeProblem;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get sendReport;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @reportSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report sent successfully'**
  String get reportSentSuccess;

  /// No description provided for @emptyReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get emptyReason;

  /// No description provided for @openPdfError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the PDF'**
  String get openPdfError;

  /// No description provided for @clientAbsent.
  ///
  /// In en, this message translates to:
  /// **'Client absent'**
  String get clientAbsent;

  /// No description provided for @addressNotFound.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get addressNotFound;

  /// No description provided for @accessImpossible.
  ///
  /// In en, this message translates to:
  /// **'Access impossible'**
  String get accessImpossible;

  /// No description provided for @missingMaterial.
  ///
  /// In en, this message translates to:
  /// **'Missing material'**
  String get missingMaterial;

  /// No description provided for @externalFailure.
  ///
  /// In en, this message translates to:
  /// **'External failure'**
  String get externalFailure;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
