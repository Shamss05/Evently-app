import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// The ARB assets contain all translations. A single delegate loads both
/// languages without generating separate language implementation files.
class AppLocalizations {
  AppLocalizations._(String locale, this._messages)
    : localeName = intl.Intl.canonicalizedLocale(locale);
  final String localeName;
  final Map<String, String> _messages;
  static final Map<String, AppLocalizations> _cache = {};
  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('ar'), Locale('en')];
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  static Future<Map<String, String>> _readMessages(String language) async {
    final content = await rootBundle.loadString(
      'lib/core/l10n/app_$language.arb',
    );
    final data = jsonDecode(content) as Map<String, dynamic>;
    return {
      for (final entry in data.entries)
        if (!entry.key.startsWith('@') && entry.value is String)
          entry.key: entry.value as String,
    };
  }

  static Future<AppLocalizations> _load(String language) async {
    final english = await _readMessages('en');
    final messages = language == 'en'
        ? english
        : {...english, ...await _readMessages(language)};
    return _cache[language] = AppLocalizations._(
      language,
      Map.unmodifiable(messages),
    );
  }

  String _text(String key) => _messages[key] ?? key;
  String _format(String key, Map<String, String> values) =>
      _text(key).replaceAllMapped(
        RegExp(r'\{(\w+)\}'),
        (match) => values[match[1]] ?? match[0]!,
      );

  String get personalizeTitle => _text('personalizeTitle');
  String get personalizeDescription => _text('personalizeDescription');
  String get language => _text('language');
  String get english => _text('english');
  String get arabic => _text('arabic');
  String get theme => _text('theme');
  String get letsStart => _text('letsStart');
  String get loginToYourAccount => _text('loginToYourAccount');
  String get createYourAccount => _text('createYourAccount');
  String get forgetPasswordTitle => _text('forgetPasswordTitle');
  String get enterYourName => _text('enterYourName');
  String get enterYourEmail => _text('enterYourEmail');
  String get enterYourPassword => _text('enterYourPassword');
  String get confirmYourPassword => _text('confirmYourPassword');
  String get forgetPasswordQuestion => _text('forgetPasswordQuestion');
  String get login => _text('login');
  String get signUp => _text('signUp');
  String get dontHaveAccount => _text('dontHaveAccount');
  String get alreadyHaveAccount => _text('alreadyHaveAccount');
  String get or => _text('or');
  String get loginWithGoogle => _text('loginWithGoogle');
  String get signUpWithGoogle => _text('signUpWithGoogle');
  String get resetPassword => _text('resetPassword');
  String get passwordResetSent => _text('passwordResetSent');
  String get passwordResetNetworkError => _text('passwordResetNetworkError');
  String get passwordResetTooManyRequests =>
      _text('passwordResetTooManyRequests');
  String get passwordResetFailed => _text('passwordResetFailed');
  String get sendingPasswordReset => _text('sendingPasswordReset');
  String get nameRequired => _text('nameRequired');
  String get invalidNameFormat => _text('invalidNameFormat');
  String get emailRequired => _text('emailRequired');
  String get invalidEmailFormat => _text('invalidEmailFormat');
  String get passwordRequired => _text('passwordRequired');
  String get passwordInvalid => _text('passwordInvalid');
  String get confirmPasswordRequired => _text('confirmPasswordRequired');
  String get passwordConfirmationMismatch =>
      _text('passwordConfirmationMismatch');
  String get skip => _text('skip');
  String get next => _text('next');
  String get getStarted => _text('getStarted');
  String get onboardingTitle1 => _text('onboardingTitle1');
  String get onboardingDescription1 => _text('onboardingDescription1');
  String get onboardingTitle2 => _text('onboardingTitle2');
  String get onboardingDescription2 => _text('onboardingDescription2');
  String get onboardingTitle3 => _text('onboardingTitle3');
  String get onboardingDescription3 => _text('onboardingDescription3');
  String get googleSignInFailed => _text('googleSignInFailed');
  String get welcome => _text('welcome');
  String get logout => _text('logout');
  String get home => _text('home');
  String get favorite => _text('favorite');
  String get profile => _text('profile');
  String get addEventTitle => _text('addEventTitle');
  String get addEvent => _text('addEvent');
  String get welcomeBack => _text('welcomeBack');
  String get changeTheme => _text('changeTheme');
  String get languageCodeLabel => _text('languageCodeLabel');
  String get englishNative => _text('englishNative');
  String get arabicNative => _text('arabicNative');
  String get darkMode => _text('darkMode');
  String get searchForEvent => _text('searchForEvent');
  String get noFavoritesYet => _text('noFavoritesYet');
  String get noMatchingEvents => _text('noMatchingEvents');
  String get noEventsInCategory => _text('noEventsInCategory');
  String eventsLoadError(String error) =>
      _format('eventsLoadError', {'error': error});
  String operationFailed(String error) =>
      _format('operationFailed', {'error': error});
  String get eventTitleLabel => _text('eventTitleLabel');
  String get eventTitleHint => _text('eventTitleHint');
  String get eventDescriptionLabel => _text('eventDescriptionLabel');
  String get eventDescriptionHint => _text('eventDescriptionHint');
  String get eventDate => _text('eventDate');
  String get eventTime => _text('eventTime');
  String get chooseDate => _text('chooseDate');
  String get chooseTime => _text('chooseTime');
  String get eventTitleRequired => _text('eventTitleRequired');
  String get eventDescriptionRequired => _text('eventDescriptionRequired');
  String get selectEventTime => _text('selectEventTime');
  String get selectEventDate => _text('selectEventDate');
  String get enterEventTitle => _text('enterEventTitle');
  String get enterEventDescription => _text('enterEventDescription');
  String get invalidData => _text('invalidData');
  String get tryAgain => _text('tryAgain');
  String get creatingEvent => _text('creatingEvent');
  String get success => _text('success');
  String get eventCreatedSuccessfully => _text('eventCreatedSuccessfully');
  String get ok => _text('ok');
  String get error => _text('error');
  String get addToFavorites => _text('addToFavorites');
  String get removeFromFavorites => _text('removeFromFavorites');
  String get categoryAll => _text('categoryAll');
  String get categorySport => _text('categorySport');
  String get categoryBirthday => _text('categoryBirthday');
  String get categoryMeeting => _text('categoryMeeting');
  String get categoryGaming => _text('categoryGaming');
  String get categoryEating => _text('categoryEating');
  String get categoryHoliday => _text('categoryHoliday');
  String get categoryExhibition => _text('categoryExhibition');
  String get categoryWorkshop => _text('categoryWorkshop');
  String get categoryBookClub => _text('categoryBookClub');
  String get eventDetails => _text('eventDetails');
  String get editEvent => _text('editEvent');
  String get updateEvent => _text('updateEvent');
  String get deleteEvent => _text('deleteEvent');
  String get cancel => _text('cancel');
  String deleteEventConfirmation(String title) =>
      _format('deleteEventConfirmation', {'title': title});
  String get eventUpdatedSuccessfully => _text('eventUpdatedSuccessfully');
  String get eventDeletedSuccessfully => _text('eventDeletedSuccessfully');
  String get eventNotFound => _text('eventNotFound');
  String categoryName(int id) => switch (id) {
    -1 => categoryAll,
    1 => categorySport,
    2 => categoryBirthday,
    3 => categoryMeeting,
    4 => categoryGaming,
    5 => categoryEating,
    6 => categoryHoliday,
    7 => categoryExhibition,
    8 => categoryWorkshop,
    9 => categoryBookClub,
    _ => categoryAll,
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  Future<AppLocalizations> load(Locale locale) {
    final cached = AppLocalizations._cache[locale.languageCode];
    return cached != null
        ? SynchronousFuture(cached)
        : AppLocalizations._load(locale.languageCode);
  }

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
