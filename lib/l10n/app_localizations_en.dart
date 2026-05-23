// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'My interventions';

  @override
  String get search => 'Search intervention...';

  @override
  String get noData => 'No intervention found';

  @override
  String get logout => 'Logout';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String hello(Object name) {
    return 'Hi $name';
  }

  @override
  String get newAlert => 'New alert';

  @override
  String get newInterventionAdded => 'New intervention added';

  @override
  String get locationCentered => 'Location centered';

  @override
  String get myInterventions => 'My\ninterventions';

  @override
  String get searchReclamation => 'Search a complaint...';

  @override
  String get status => 'Status';

  @override
  String get all => 'All';

  @override
  String get opened => 'Open';

  @override
  String get inProgress => 'In progress';

  @override
  String get finished => 'Finished';

  @override
  String get show => 'Show';

  @override
  String get noInterventionFound => 'No intervention found';

  @override
  String get noType => 'No type';

  @override
  String get unknownClient => 'Unknown client';

  @override
  String get reclamationNumber => 'Complaint';

  @override
  String get clientLabel => 'Client';

  @override
  String get invalidInterventionId => 'Invalid intervention ID';

  @override
  String unprocessedDerangementsCount(int count) {
    return 'You have $count unprocessed incidents';
  }

  @override
  String get quickMenu => 'Quick Menu';

  @override
  String get seeAll => 'See all';

  @override
  String get mapDerangements => 'Map\nissues';

  @override
  String get alerts => 'View\nalerts';

  @override
  String get dailyStats => 'Daily\nstats';

  @override
  String get history => 'History';

  @override
  String get fullHistory => 'Full history';

  @override
  String get finishedInterventions => 'Finished interventions';

  @override
  String get pendingTickets => 'Pending tickets';

  @override
  String get slaRespected => 'SLA respected';

  @override
  String get averageTime => 'Average time';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get comingSoon => 'coming soon';

  @override
  String get generatingKpiReport => 'Generating KPI report...';

  @override
  String get kpiReportGenerated => 'KPI report generated successfully';

  @override
  String get kpi => 'KPI';

  @override
  String get performance => 'Performance';

  @override
  String get interventions => 'interventions';

  @override
  String get vacationMode => 'Vacation mode';

  @override
  String get vacationActive => 'You are currently on vacation';

  @override
  String get vacationInactive => 'You are available for work';

  @override
  String get vacationConfirmTitle => 'Confirmation';

  @override
  String get vacationConfirmMessage => 'Are you sure you want to switch to vacation mode?';

  @override
  String get backConfirmTitle => 'Back to work';

  @override
  String get backConfirmMessage => 'Are you sure you want to return to active mode?';

  @override
  String get happyVacation => 'Happy vacation! We wish you a joyful vacation.';

  @override
  String get welcomeBack => 'Glad to see you again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get itinerary => 'Route';

  @override
  String get call => 'Call';

  @override
  String get start => 'Start';

  @override
  String get problem => 'Problem';

  @override
  String get camera => 'Camera';

  @override
  String get close => 'Close';

  @override
  String get description => 'Description';

  @override
  String get reclamation => 'Complaint';

  @override
  String get routeError => 'Unable to open route';

  @override
  String get callError => 'Unable to open call';

  @override
  String get invalidId => 'Invalid complaint ID';

  @override
  String get started => 'Intervention started';

  @override
  String get phoneUnavailable => 'Phone number unavailable';

  @override
  String get serviceType => 'Service type';

  @override
  String get address => 'Address';

  @override
  String get slaMissed => 'SLA Missed';

  @override
  String get slaSoon => 'SLA Soon';

  @override
  String get client => 'Client';

  @override
  String get phone => 'Phone';

  @override
  String get errorReport => 'Error Report';

  @override
  String get company => 'Algeria Telecom';

  @override
  String get systemDate => 'System date';

  @override
  String get problemReason => 'Problem reason';

  @override
  String get describeProblem => 'Describe the problem...';

  @override
  String get sendReport => 'Send report';

  @override
  String get sending => 'Sending...';

  @override
  String get reportSentSuccess => 'Report sent successfully';

  @override
  String get emptyReason => 'Please enter a reason';

  @override
  String get openPdfError => 'Unable to open the PDF';

  @override
  String get clientAbsent => 'Client absent';

  @override
  String get addressNotFound => 'Address not found';

  @override
  String get accessImpossible => 'Access impossible';

  @override
  String get missingMaterial => 'Missing material';

  @override
  String get externalFailure => 'External failure';

  @override
  String get other => 'Other';
}
