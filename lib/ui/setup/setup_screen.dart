import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../login/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SetupScreen extends StatefulWidget {
  static const String routeName = "/setup";

  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late AppConfig provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AppConfig>(context);
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 16,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/app_logo_${provider.themeMode == ThemeMode.light ? "light" : "dark"}.png",
                  width: MediaQuery.sizeOf(context).width * .4,
                ),
              ),
              Expanded(
                child: Image.asset(
                  "assets/images/setup_image_${provider.themeMode == ThemeMode.light ? "light" : "dark"}.png",
                ),
              ),
              Text(
                locale.personalizeTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                locale.personalizeDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                spacing: 8,
                children: [
                  Text(
                    locale.language,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Spacer(),
                  _buildOptionChip(
                    provider.locale == "en",
                    () {
                      provider.changeLocale("en");
                    },
                    Text(
                      locale.english,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: _getChipColor(provider.locale == "en"),
                      ),
                    ),
                  ),
                  _buildOptionChip(
                    provider.locale == "ar",
                    () {
                      provider.changeLocale("ar");
                    },
                    Text(
                      locale.arabic,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: _getChipColor(provider.locale == "ar"),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  Text(
                    locale.theme,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Spacer(),
                  _buildOptionChip(
                    provider.themeMode == ThemeMode.light,
                    () {
                      provider.changeTheme(ThemeMode.light);
                    },
                    Icon(Icons.light_mode, color: _getChipColor(true)),
                  ),
                  _buildOptionChip(
                    provider.themeMode == ThemeMode.dark,
                    () {
                      provider.changeTheme(ThemeMode.dark);
                    },
                    Icon(Icons.dark_mode, color: _getChipColor(false)),
                  ),
                ],
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    provider.hasSeenOnboarding
                        ? LoginScreen.routeName
                        : OnboardingScreen.routeName,
                  );
                },
                child: Text(locale.letsStart),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getChipColor(bool isSelected) {
    return provider.themeMode == ThemeMode.light
        ? isSelected
              ? LightAppColors().inputColor
              : LightAppColors().mainColor
        : DarkAppColors().mainTextColor;
  }

  Widget _buildOptionChip(bool isSelected, Function onPress, Widget child) {
    return InkWell(
      onTap: () {
        onPress();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        child: child,
      ),
    );
  }
}
