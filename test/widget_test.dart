import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:assignment_6/core/config/app_config.dart';
import 'package:assignment_6/main.dart';
import 'package:assignment_6/ui/login/login_screen.dart';
import 'package:assignment_6/ui/setup/setup_screen.dart';
import 'package:assignment_6/ui/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_screens_test.dart' as support;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await AppLocalizations.delegate.load(const Locale('en'));
    await AppLocalizations.delegate.load(const Locale('ar'));
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = support.TestAuth();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('New install opens splash and setup', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppConfig('en', ThemeMode.light),
        child: const MyApp(),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(SetupScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Returning signed-out user reaches login', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) =>
            AppConfig('en', ThemeMode.light, hasSeenOnboarding: true),
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
