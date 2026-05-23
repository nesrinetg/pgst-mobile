// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'Mes interventions';

  @override
  String get search => 'Rechercher une intervention...';

  @override
  String get noData => 'Aucune intervention trouvée';

  @override
  String get logout => 'Déconnexion';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String hello(Object name) {
    return 'Salut $name';
  }

  @override
  String get newAlert => 'Nouvelle alerte';

  @override
  String get newInterventionAdded => 'Nouvelle intervention ajoutée';

  @override
  String get locationCentered => 'Position centrée';

  @override
  String get myInterventions => 'Mes interventions';

  @override
  String get searchReclamation => 'Rechercher une réclamation...';

  @override
  String get status => 'Statut';

  @override
  String get all => 'Tous';

  @override
  String get opened => 'Ouverte';

  @override
  String get inProgress => 'En cours';

  @override
  String get finished => 'Terminée';

  @override
  String get show => 'Afficher';

  @override
  String get noInterventionFound => 'Aucune intervention trouvée';

  @override
  String get noType => 'Sans type';

  @override
  String get unknownClient => 'Client inconnu';

  @override
  String get reclamationNumber => 'Réclamation';

  @override
  String get clientLabel => 'Client';

  @override
  String get invalidInterventionId => 'ID intervention invalide';

  @override
  String unprocessedDerangementsCount(int count) {
    return 'Vous avez $count dérangements non traités';
  }

  @override
  String get quickMenu => 'Quick Menu';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get mapDerangements => 'Carte\ndérangements';

  @override
  String get alerts => 'Voir les\nalertes';

  @override
  String get dailyStats => 'Stats\njournalières';

  @override
  String get history => 'Historique';

  @override
  String get fullHistory => 'Historique complet';

  @override
  String get finishedInterventions => 'Interventions terminées';

  @override
  String get pendingTickets => 'Tickets en attente';

  @override
  String get slaRespected => 'SLA respecté';

  @override
  String get averageTime => 'Temps moyen';

  @override
  String get day => 'Jour';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get comingSoon => 'sera ajouté après';

  @override
  String get generatingKpiReport => 'Génération du rapport KPI...';

  @override
  String get kpiReportGenerated => 'Rapport KPI généré avec succès';

  @override
  String get kpi => 'KPI';

  @override
  String get performance => 'Performance';

  @override
  String get interventions => 'interventions';

  @override
  String get vacationMode => 'Mode vacances';

  @override
  String get vacationActive => 'Vous êtes actuellement en vacances';

  @override
  String get vacationInactive => 'Vous êtes disponible pour travailler';

  @override
  String get vacationConfirmTitle => 'Confirmation';

  @override
  String get vacationConfirmMessage => 'Êtes-vous sûr de vouloir passer en mode vacances ?';

  @override
  String get backConfirmTitle => 'Retour au travail';

  @override
  String get backConfirmMessage => 'Êtes-vous sûr de vouloir revenir au mode actif ?';

  @override
  String get happyVacation => 'Bonnes vacances ! On vous souhaite de joyeuses vacances.';

  @override
  String get welcomeBack => 'Ravi de vous revoir.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get itinerary => 'Itinéraire';

  @override
  String get call => 'Appeler';

  @override
  String get start => 'Commencer';

  @override
  String get problem => 'Problème';

  @override
  String get camera => 'Caméra';

  @override
  String get close => 'Fermer';

  @override
  String get description => 'Description';

  @override
  String get reclamation => 'Réclamation';

  @override
  String get routeError => 'Impossible d’ouvrir l’itinéraire';

  @override
  String get callError => 'Impossible d’ouvrir l’appel';

  @override
  String get invalidId => 'ID de réclamation invalide';

  @override
  String get started => 'Intervention commencée';

  @override
  String get phoneUnavailable => 'Numéro de téléphone indisponible';

  @override
  String get serviceType => 'Type de service';

  @override
  String get address => 'Adresse';

  @override
  String get slaMissed => 'SLA dépassé';

  @override
  String get slaSoon => 'SLA proche';

  @override
  String get client => 'Client';

  @override
  String get phone => 'Téléphone';

  @override
  String get errorReport => 'Déclaration d’erreur';

  @override
  String get company => 'Algérie Télécom';

  @override
  String get systemDate => 'Date système';

  @override
  String get problemReason => 'Motif du problème';

  @override
  String get describeProblem => 'Décrivez le problème...';

  @override
  String get sendReport => 'Envoyer la déclaration';

  @override
  String get sending => 'Envoi...';

  @override
  String get reportSentSuccess => 'Déclaration envoyée avec succès';

  @override
  String get emptyReason => 'Veuillez saisir un motif';

  @override
  String get openPdfError => 'Impossible d’ouvrir le PDF';

  @override
  String get clientAbsent => 'Client absent';

  @override
  String get addressNotFound => 'Adresse introuvable';

  @override
  String get accessImpossible => 'Accès impossible';

  @override
  String get missingMaterial => 'Matériel manquant';

  @override
  String get externalFailure => 'Panne externe';

  @override
  String get other => 'Autre';
}
