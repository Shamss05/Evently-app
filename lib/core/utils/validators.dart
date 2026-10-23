

import '../l10n/app_localizations.dart';

typedef ValidationFunction = String? Function(String?);

class Validator {
  final RegExp _nameRegex = RegExp(r"^[\p{L}\s'\-\.]+$", unicode: true);

  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
  );

  String? nameValidation(String? input, AppLocalizations locale) {
    if (input == null || input.trim().isEmpty) {
      return locale.nameRequired;
    }
    if (!_nameRegex.hasMatch(input.trim())) {
      return locale.invalidNameFormat;
    }
    return null;
  }

  String? emailValidation(String? input, AppLocalizations locale) {
    if (input == null || input.trim().isEmpty) {
      return locale.emailRequired;
    }
    if (!_emailRegex.hasMatch(input.trim())) {
      return locale.invalidEmailFormat;
    }
    return null;
  }

  String? passwordValidation(String? input, AppLocalizations locale) {
    if (input == null || input.isEmpty) {
      return locale.passwordRequired;
    }
    if (!_passwordRegex.hasMatch(input)) {
      return locale.passwordInvalid;
    }
    return null;
  }

  String? passwordConfirmationValidation(
    String? input,
    String? password,
    AppLocalizations locale,
  ) {
    if (input == null || input.isEmpty) {
      return locale.confirmPasswordRequired;
    }
    if (input != password) {
      return locale.passwordConfirmationMismatch;
    }
    return null;
  }
}
