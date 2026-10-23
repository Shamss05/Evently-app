import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:assignment_6/ui/event_details/event_details_screen.dart';
import 'event_management_test.dart' as management;
import 'package:flutter/cupertino.dart';
import 'package:assignment_6/ui/home/home_screen.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:assignment_6/core/config/app_config.dart';
import 'package:assignment_6/models/event_dm.dart';
import 'package:assignment_6/models/category_dm.dart';
import 'package:assignment_6/ui/home/home_tab/widgets/home_header.dart';
import 'package:assignment_6/ui/home/home_tab/widgets/even_card.dart';
import 'package:assignment_6/ui/home/profile_tab/profile_tab.dart';
import 'package:assignment_6/ui/manage_events/manage_events_screen.dart';
import 'event_screens_test.dart' as support;

class _MultiFactor extends MultiFactorPlatform {
  _MultiFactor(super.auth);
}

class _User extends UserPlatform {
  _User(FirebaseAuthPlatform auth)
    : super(
        auth,
        _MultiFactor(auth),
        InternalUserDetails(
          userInfo: InternalUserInfo(
            uid: 'preview-user',
            displayName: 'John Smith',
            email: 'johnsmith@example.com',
            isAnonymous: false,
            isEmailVerified: true,
          ),
          providerData: [],
        ),
      );
}

class _Auth extends support.TestAuth {
  @override
  UserPlatform? get currentUser => _User(this);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await AppLocalizations.delegate.load(const Locale('en'));
    await AppLocalizations.delegate.load(const Locale('ar'));
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = _Auth();
    final cupertino = FontLoader('packages/cupertino_icons/CupertinoIcons')
      ..addFont(
        rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      );
    await cupertino.load();
    final sdk = Platform.environment['FLUTTER_ROOT'];
    if (sdk != null) {
      for (final font in {
        'Roboto': 'roboto-regular.ttf',
        'MaterialIcons': 'materialicons-regular.otf',
      }.entries) {
        final loader = FontLoader(font.key);
        loader.addFont(
          File(
            '$sdk/bin/cache/artifacts/material_fonts/${font.value}',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
        if (font.key == 'Roboto') {
          for (final weight in [
            'roboto-medium.ttf',
            'roboto-bold.ttf',
            'roboto-black.ttf',
          ]) {
            loader.addFont(
              File(
                '$sdk/bin/cache/artifacts/material_fonts/$weight',
              ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
            );
          }
        }
        await loader.load();
      }
    }
  });
  testWidgets('Phone layouts render without overflow', (tester) async {
    final originalShadows = debugDisableShadows;
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = originalShadows);
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final config = AppConfig('en', ThemeMode.light);
    final theme = config.lightAppTheme;
    final key = GlobalKey();
    Future<void> capture(String name, Widget child) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: config,
          child: support.LocalizedTestApp(
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
            ),
            home: RepaintBoundary(key: key, child: child),
          ),
        ),
      );
      await tester.pump();
      // Asset decoding is asynchronous engine work.
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 700)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final output = Platform.environment['EVENTLY_CAPTURE_DIR'];
      if (output != null) {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$output/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }

    final events = [categoriesList[1], categoriesList[2], categoriesList[6]]
        .map(
          (category) => EventDm(
            id: '${category.id}',
            title: category.id == 2
                ? 'This is my birthday party'
                : 'Meeting for updating the development roadmap',
            description: '',
            date: DateTime(2026, 1, 22).millisecondsSinceEpoch,
            time: 0,
            category: category,
            favoriteUsers: const ['preview-user'],
          ),
        )
        .toList();
    await capture(
      'home-preview',
      Scaffold(
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {},
          child: const Icon(Icons.add, size: 22),
        ),
        bottomNavigationBar: HomeNavigation(
          selectedIndex: 0,
          onChanged: (_) {},
        ),
        body: Column(
          children: [
            HomeHeader(
              categoriesList: [
                CategoryDm(-1, '', Icons.grid_view),
                ...categoriesList,
              ],
              selectedCategory: CategoryDm(-1, '', Icons.grid_view),
              changeSelectedCategory: (_) {},
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, i) => EventCard(eventDm: events[i]),
              ),
            ),
          ],
        ),
      ),
    );
    await capture(
      'profile-preview',
      Scaffold(
        body: const ProfileTab(),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {},
          child: const Icon(Icons.add, size: 22),
        ),
        bottomNavigationBar: HomeNavigation(
          selectedIndex: 2,
          onChanged: (_) {},
        ),
      ),
    );
    await capture('add-event-preview', const ManageEventsScreen());
    final previewEvent = management.sampleEvent();
    previewEvent.description =
        'Lorem ipsum dolor sit amet consectetur. Vulputate eleifend suscipit eget neque senectus a. Nulla at non malesuada odio duis lectus amet nisi sit. Risus hac enim maecenas auctor et. At cras massa diam porta facilisi lacus purus. Iaculis eget quis ut amet. Sit ac malesuada nisi quis feugiat.';
    final previewRepository = management.MemoryEvents(previewEvent);
    await capture(
      'event-details-preview',
      EventDetailsScreen(event: previewEvent, repository: previewRepository),
    );
    final editEvent = EventDm(
      id: previewEvent.id,
      title: 'Reading book club',
      description: previewEvent.description,
      date: DateTime(2026, 1, 30).millisecondsSinceEpoch,
      time: DateTime(2026, 1, 30, 11, 22).millisecondsSinceEpoch,
      category: categoriesList.last,
      userId: previewEvent.userId,
      favoriteUsers: previewEvent.favoriteUsers,
    );
    await capture(
      'edit-event-preview',
      ManageEventsScreen(event: editEvent, repository: previewRepository),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await previewRepository.changes.close();
    debugDisableShadows = originalShadows;
  });
  testWidgets('Reference card uses a single-line badge and outlined favorite', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final config = AppConfig('en', ThemeMode.light);
    final key = GlobalKey();
    final theme = config.lightAppTheme;
    final event = EventDm(
      id: 'reference',
      title: 'Meeting for Updating The Development Method',
      description: '',
      date: DateTime(2026, 1, 22).millisecondsSinceEpoch,
      time: 0,
      category: categoriesList[2],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: config,
        child: support.LocalizedTestApp(
          theme: theme.copyWith(
            textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
          ),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(width: 361, child: EventCard(eventDm: event)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pumpAndSettle();
    expect(find.text('22 Jan'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
    expect(tester.takeException(), isNull);
    final output = Platform.environment['EVENTLY_CAPTURE_DIR'];
    if (output != null) {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '$output/event-card-preview.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
