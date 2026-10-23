import 'dart:async';
import 'package:assignment_6/core/config/app_config.dart';
import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:assignment_6/firebase/firebase_auth_service.dart';
import 'package:assignment_6/ui/forget_password/forget_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'event_screens_test.dart' show LocalizedTestApp;

class ResetService extends FirebaseAuthService {
  final calls = <String>[];
  Completer<void>? pending;
  Object? error;
  @override
  Future<void> forgetPassword(String email) async {
    calls.add(email);
    if (pending != null) await pending!.future;
    if (error != null) throw error!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await AppLocalizations.delegate.load(const Locale('en'));
    await AppLocalizations.delegate.load(const Locale('ar'));
  });
  Future<void> open(
    WidgetTester tester,
    ResetService service, {
    String language = 'en',
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppConfig(language, ThemeMode.light),
        child: LocalizedTestApp(
          home: ForgetPasswordScreen(authService: service),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
  }

  testWidgets('Rejects empty and invalid emails without sending', (
    tester,
  ) async {
    final service = ResetService();
    await open(tester, service);
    await submit(tester);
    expect(find.text('Email is required'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'invalid');
    await submit(tester);
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(service.calls, isEmpty);
  });
  testWidgets('Trims email, prevents duplicate sends, and shows success', (
    tester,
  ) async {
    final service = ResetService()..pending = Completer<void>();
    await open(tester, service);
    await tester.enterText(find.byType(TextFormField), ' user@example.com ');
    await submit(tester);
    expect(service.calls, ['user@example.com']);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    service.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.textContaining('Check your inbox'), findsOneWidget);
  });
  testWidgets('Network failure allows retry', (tester) async {
    final service = ResetService()
      ..error = FirebaseAuthException(code: 'network-request-failed');
    await open(tester, service);
    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await submit(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    service.error = null;
    await submit(tester);
    await tester.pumpAndSettle();
    expect(service.calls.length, 2);
    expect(find.textContaining('Check your inbox'), findsOneWidget);
  });
  testWidgets('Arabic reset result uses Arabic translation', (tester) async {
    final service = ResetService()
      ..error = FirebaseAuthException(code: 'too-many-requests');
    await open(tester, service, language: 'ar');
    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await submit(tester);
    await tester.pumpAndSettle();
    final locale = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(locale.passwordResetTooManyRequests), findsOneWidget);
  });
  testWidgets(
    'Completing after leaving screen does not update disposed state',
    (tester) async {
      final service = ResetService()..pending = Completer<void>();
      await open(tester, service);
      await tester.enterText(find.byType(TextFormField), 'user@example.com');
      await submit(tester);
      await tester.pumpWidget(const SizedBox());
      service.pending!.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

