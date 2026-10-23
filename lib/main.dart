import 'package:assignment_6/ui/forget_password/forget_password_screen.dart';
import 'package:assignment_6/ui/home/home_screen.dart';
import 'package:assignment_6/ui/login/login_screen.dart';
import 'package:assignment_6/ui/manage_events/manage_events_screen.dart';
import 'package:assignment_6/ui/onboarding/onboarding_screen.dart';
import 'package:assignment_6/ui/setup/setup_screen.dart';
import 'package:assignment_6/ui/signup/signup_screen.dart';
import 'package:assignment_6/ui/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/l10n/app_localizations.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var theme = sharedPreferences.getBool("theme") ?? true
      ? ThemeMode.light
      : ThemeMode.dark;
  var locale = sharedPreferences.getString("locale") ?? "en";
  var hasSeenOnboarding =
      sharedPreferences.getBool("hasSeenOnboarding") ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          AppConfig(locale, theme, hasSeenOnboarding: hasSeenOnboarding),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConfig>(
      builder: (context, provider, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: provider.lightAppTheme,
        darkTheme: provider.darkAppTheme,
        themeMode: provider.themeMode,
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(provider.locale),
        routes: {
          SplashScreen.routeName: (_) => SplashScreen(),
          OnboardingScreen.routeName: (_) => OnboardingScreen(),
          SetupScreen.routeName: (_) => SetupScreen(),
          LoginScreen.routeName: (_) => LoginScreen(),
          SignupScreen.routeName: (_) => SignupScreen(),
          HomeScreen.routeName: (_) => HomeScreen(),
          ForgetPasswordScreen.routeName: (_) => ForgetPasswordScreen(),
          ManageEventsScreen.routeName: (_) => const ManageEventsScreen(),
        },
        initialRoute: SplashScreen.routeName,
      ),
    );
  }
}
