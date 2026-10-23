import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:assignment_6/ui/widgets/category_artwork.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase's test helpers and platform fake avoid contacting a real account.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assignment_6/ui/home/profile_tab/profile_tab.dart';
import 'package:assignment_6/ui/home/home_tab/widgets/home_header.dart';
import 'package:assignment_6/core/config/app_config.dart';
import 'package:assignment_6/models/category_dm.dart';
import 'package:assignment_6/ui/manage_events/manage_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class TestAuth extends FirebaseAuthPlatform {
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;
  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) => this;
  @override
  UserPlatform? get currentUser => null;
}

class LocalizedTestApp extends StatelessWidget {
  final Widget home;
  final ThemeData? theme;
  const LocalizedTestApp({super.key, required this.home, this.theme});
  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    return MaterialApp(
      theme: theme ?? config.lightAppTheme,
      darkTheme: config.darkAppTheme,
      themeMode: config.themeMode,
      locale: Locale(config.locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await AppLocalizations.delegate.load(const Locale('en'));
    await AppLocalizations.delegate.load(const Locale('ar'));
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = TestAuth();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Profile switches theme and language using existing settings', (
    tester,
  ) async {
    final config = AppConfig('en', ThemeMode.light);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: config,
        child: const LocalizedTestApp(home: Scaffold(body: ProfileTab())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(config.isDark(), isTrue);
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();
    expect(config.locale, 'ar');
    expect(find.text('تسجيل الخروج'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home category chips call the selected category', (tester) async {
    CategoryDm? selected;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppConfig('en', ThemeMode.light),
        child: LocalizedTestApp(
          home: Scaffold(
            body: HomeHeader(
              categoriesList: categoriesList,
              selectedCategory: categoriesList.first,
              changeSelectedCategory: (value) => selected = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthday'));
    await tester.pump();
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(selected?.id, 2);
    expect(tester.takeException(), isNull);
  });

  Future<void> openForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppConfig('en', ThemeMode.light),
        child: const LocalizedTestApp(home: ManageEventsScreen()),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 700)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Imported add-event layout changes artwork with category', (
    tester,
  ) async {
    await openForm(tester);
    expect(find.text('Add event'), findsOneWidget);
    final buttonBottom = tester.getRect(find.byType(FilledButton)).bottom;
    expect(
      tester.view.physicalSize.height - buttonBottom,
      lessThanOrEqualTo(16),
    );
    await tester.drag(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListView && widget.scrollDirection == Axis.horizontal,
      ),
      const Offset(-160, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthday'));
    await tester.pump();
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    final artwork = tester.widget<CategoryArtwork>(
      find.byType(CategoryArtwork),
    );
    expect(artwork.asset, categoriesList[1].imagePath);
    final image = tester.widget<Image>(find.byType(Image).first);
    expect(
      (image.image as AssetImage).assetName,
      'assets/categories/light/birthday.png',
    );
    expect(image.gaplessPlayback, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Add event rejects missing title description date and time', (
    tester,
  ) async {
    await openForm(tester);
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid Data'), findsOneWidget);
    expect(find.textContaining('Select Event Date'), findsOneWidget);
    expect(find.textContaining('Select Event Time'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid Data'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Footer respects gesture area and form scrolls on small phones', (
    tester,
  ) async {
    await openForm(tester);
    tester.view.physicalSize = const Size(390, 680);
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(FilledButton)).bottom, closeTo(646, 1));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Event Time').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Arabic form uses ARB labels categories and validation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppConfig('ar', ThemeMode.light),
        child: const LocalizedTestApp(home: ManageEventsScreen()),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 700)),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(ManageEventsScreen));
    final locale = AppLocalizations.of(context)!;
    expect(locale.localeName, 'ar');
    expect(find.text(locale.categoryBookClub), findsOneWidget);
    expect(find.text(locale.eventTitleLabel), findsOneWidget);
    expect(Directionality.of(context), TextDirection.rtl);
    await tester.tap(find.text(locale.addEvent).last);
    await tester.pumpAndSettle();
    expect(find.text(locale.invalidData), findsOneWidget);
    expect(find.textContaining(locale.selectEventDate), findsOneWidget);
    expect(find.text(locale.eventTitleRequired), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
