import '../l10n/app_localizations.dart';

class DataValidator {
  static String? titleValidation(String? input, AppLocalizations locale) {
    if (input == null || input.trim().isEmpty) {
      return locale.eventTitleRequired;
    }
    return null;
  }

  static String? descriptionValidation(String? input, AppLocalizations locale) {
    if (input == null || input.trim().isEmpty) {
      return locale.eventDescriptionRequired;
    }
    return null;
  }
}
