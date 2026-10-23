import 'dart:io';
import 'dart:convert';
import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cold startup loads ARB assets and language switches correctly', (
    tester,
  ) async {
    Widget app(Locale locale) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) =>
            Scaffold(body: Text(AppLocalizations.of(context)!.home)),
      ),
    );
    await tester.pumpWidget(app(const Locale('en')));
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    await tester.pumpWidget(app(const Locale('ar')));
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold));
    expect(AppLocalizations.of(context)!.localeName, 'ar');
    expect(find.text(AppLocalizations.of(context)!.home), findsOneWidget);
    expect(Directionality.of(context), TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });

  test('ARB files provide matching translation keys', () async {
    final en =
        jsonDecode(File('lib/core/l10n/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;
    final ar =
        jsonDecode(File('lib/core/l10n/app_ar.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(
      ar.keys.where((key) => !key.startsWith('@')).toSet(),
      en.keys.where((key) => !key.startsWith('@')).toSet(),
    );
  });

  test('Single delegate loads languages and category names', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(en.localeName, 'en');
    expect(ar.localeName, 'ar');
    expect(en.editEvent, 'Edit event');
    expect(ar.editEvent, isNot(en.editEvent));
    expect(en.categoryName(3), en.categoryMeeting);
    expect(ar.categoryName(3), ar.categoryMeeting);
    expect(en.categoryName(-1), en.categoryAll);
    expect(ar.categoryName(999), ar.categoryAll);
  });

  test(
    'Placeholders preserve user text without a second substitution',
    () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      const title = r'Meeting {error} $100';
      expect(en.deleteEventConfirmation(title), contains(title));
      expect(ar.deleteEventConfirmation(title), contains(title));
      expect(en.operationFailed('offline'), contains('offline'));
      expect(ar.eventsLoadError('offline'), contains('offline'));
    },
  );
}
