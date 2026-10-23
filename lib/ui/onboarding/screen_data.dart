import '../../core/l10n/app_localizations.dart';

class OnboardingPageData {
  final String lightImage;
  final String darkImage;
  final String Function(AppLocalizations locale) title;
  final String Function(AppLocalizations locale) description;

  const OnboardingPageData({
    required this.lightImage,
    required this.darkImage,
    required this.title,
    required this.description,
  });

  String imageFor(bool isLight) => isLight ? lightImage : darkImage;
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    lightImage: 'assets/images/onboarding1_light.png',
    darkImage: 'assets/images/onboarding1_dark.png',
    title: _title1,
    description: _description1,
  ),
  OnboardingPageData(
    lightImage: 'assets/images/onboarding2_light.png',
    darkImage: 'assets/images/onboarding2_dark.png',
    title: _title2,
    description: _description2,
  ),
  OnboardingPageData(
    lightImage: 'assets/images/onboarding3_light.png',
    darkImage: 'assets/images/onboarding3_dark.png',
    title: _title3,
    description: _description3,
  ),
];

String _title1(AppLocalizations locale) => locale.onboardingTitle1;

String _description1(AppLocalizations locale) => locale.onboardingDescription1;

String _title2(AppLocalizations locale) => locale.onboardingTitle2;

String _description2(AppLocalizations locale) => locale.onboardingDescription2;

String _title3(AppLocalizations locale) => locale.onboardingTitle3;

String _description3(AppLocalizations locale) => locale.onboardingDescription3;
