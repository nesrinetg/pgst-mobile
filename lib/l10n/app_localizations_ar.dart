// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get title => 'تدخلاتي';

  @override
  String get search => 'ابحث عن تدخل...';

  @override
  String get noData => 'لا توجد تدخلات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String hello(Object name) {
    return 'مرحبا $name';
  }

  @override
  String get newAlert => 'تنبيه جديد';

  @override
  String get newInterventionAdded => 'تمت إضافة تدخل جديد';

  @override
  String get locationCentered => 'تم توسيط الموقع';

  @override
  String get myInterventions => 'تدخلاتي';

  @override
  String get searchReclamation => 'ابحث عن شكوى...';

  @override
  String get status => 'الحالة';

  @override
  String get all => 'الكل';

  @override
  String get opened => 'مفتوحة';

  @override
  String get inProgress => 'قيد المعالجة';

  @override
  String get finished => 'منتهية';

  @override
  String get show => 'عرض';

  @override
  String get noInterventionFound => 'لم يتم العثور على أي تدخل';

  @override
  String get noType => 'بدون نوع';

  @override
  String get unknownClient => 'عميل غير معروف';

  @override
  String get reclamationNumber => 'الشكوى';

  @override
  String get clientLabel => 'العميل';

  @override
  String get invalidInterventionId => 'معرّف التدخل غير صالح';

  @override
  String unprocessedDerangementsCount(int count) {
    return 'لديك $count أعطال غير معالجة';
  }

  @override
  String get quickMenu => 'القائمة السريعة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get mapDerangements => 'خريطة\nالأعطال';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get dailyStats => 'إحصائيات\nيومية';

  @override
  String get history => 'السجل';

  @override
  String get fullHistory => 'السجل الكامل';

  @override
  String get finishedInterventions => 'تدخلات منتهية';

  @override
  String get pendingTickets => 'طلبات قيد الانتظار';

  @override
  String get slaRespected => 'احترام SLA';

  @override
  String get averageTime => 'الوقت المتوسط';

  @override
  String get day => 'يوم';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get year => 'سنة';

  @override
  String get comingSoon => 'سيتم إضافته لاحقًا';

  @override
  String get generatingKpiReport => 'جاري إنشاء التقرير...';

  @override
  String get kpiReportGenerated => 'تم إنشاء التقرير بنجاح';

  @override
  String get kpi => 'مؤشرات الأداء';

  @override
  String get performance => 'الأداء';

  @override
  String get interventions => 'تدخلات';

  @override
  String get vacationMode => 'وضع العطلة';

  @override
  String get vacationActive => 'أنت حالياً في عطلة';

  @override
  String get vacationInactive => 'أنت متاح للعمل';

  @override
  String get vacationConfirmTitle => 'تأكيد';

  @override
  String get vacationConfirmMessage => 'هل أنت متأكد أنك تريد تفعيل وضع العطلة؟';

  @override
  String get backConfirmTitle => 'العودة إلى العمل';

  @override
  String get backConfirmMessage => 'هل أنت متأكد أنك تريد العودة إلى الوضع النشط؟';

  @override
  String get happyVacation => 'عطلة سعيدة! نتمنى لك إجازة ممتعة.';

  @override
  String get welcomeBack => 'سعداء بعودتك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get itinerary => 'المسار';

  @override
  String get call => 'اتصال';

  @override
  String get start => 'ابدأ';

  @override
  String get problem => 'مشكلة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get close => 'إغلاق';

  @override
  String get description => 'الوصف';

  @override
  String get reclamation => 'الشكوى';

  @override
  String get routeError => 'تعذر فتح المسار';

  @override
  String get callError => 'تعذر فتح الاتصال';

  @override
  String get invalidId => 'رقم الشكوى غير صالح';

  @override
  String get started => 'تم بدء التدخل';

  @override
  String get phoneUnavailable => 'رقم الهاتف غير متوفر';

  @override
  String get serviceType => 'نوع الخدمة';

  @override
  String get address => 'العنوان';

  @override
  String get slaMissed => 'تجاوز مهلة SLA';

  @override
  String get slaSoon => 'SLA قريب';

  @override
  String get client => 'الزبون';

  @override
  String get phone => 'الهاتف';

  @override
  String get errorReport => 'تصريح خطأ';

  @override
  String get company => 'اتصالات الجزائر';

  @override
  String get systemDate => 'تاريخ النظام';

  @override
  String get problemReason => 'سبب المشكل';

  @override
  String get describeProblem => 'صف المشكل...';

  @override
  String get sendReport => 'إرسال التصريح';

  @override
  String get sending => 'جارٍ الإرسال...';

  @override
  String get reportSentSuccess => 'تم إرسال التصريح بنجاح';

  @override
  String get emptyReason => 'يرجى إدخال السبب';

  @override
  String get openPdfError => 'تعذر فتح ملف PDF';

  @override
  String get clientAbsent => 'الزبون غائب';

  @override
  String get addressNotFound => 'العنوان غير موجود';

  @override
  String get accessImpossible => 'الدخول غير ممكن';

  @override
  String get missingMaterial => 'المعدات ناقصة';

  @override
  String get externalFailure => 'عطل خارجي';

  @override
  String get other => 'أخرى';
}
