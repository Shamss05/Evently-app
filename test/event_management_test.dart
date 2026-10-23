import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'dart:async';
import 'package:assignment_6/core/config/app_config.dart';
import 'package:assignment_6/firebase/events_database.dart';
import 'package:assignment_6/models/category_dm.dart';
import 'package:assignment_6/models/event_dm.dart';
import 'package:assignment_6/ui/event_details/event_details_screen.dart';
import 'package:assignment_6/ui/home/home_tab/widgets/even_card.dart';
import 'package:assignment_6/ui/manage_events/manage_events_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'event_screens_test.dart' as support;

class MemoryEvents implements EventRepository {
  EventDm? current;
  MemoryEvents(this.current);
  final changes = StreamController<EventDm?>.broadcast(sync: true);
  int updates = 0;
  int deletes = 0;
  bool failUpdate = false;
  bool failDelete = false;
  Completer<void>? pendingSave;
  @override
  Stream<EventDm?> watchEvent(String id) async* {
    yield current;
    yield* changes.stream;
  }

  @override
  Future<void> createEvent(EventDm event) async {
    current = event;
    changes.add(event);
  }

  @override
  Future<void> updateEvent(EventDm event) async {
    updates++;
    if (pendingSave != null) await pendingSave!.future;
    if (failUpdate) throw StateError('Save failed');
    current = EventDm(
      id: event.id,
      title: event.title,
      description: event.description,
      date: event.date,
      time: event.time,
      category: event.category,
      favoriteUsers: current!.favoriteUsers,
      userId: current!.userId,
    );
    changes.add(current);
  }

  @override
  Future<void> deleteEvent(String id) async {
    deletes++;
    if (failDelete) throw StateError('Delete failed');
    current = null;
    changes.add(null);
  }
}

EventDm sampleEvent() => EventDm(
  id: 'event-1',
  title: 'We are going to play football',
  description: 'Original event description',
  date: DateTime(2026, 1, 21).millisecondsSinceEpoch,
  time: DateTime(2026, 1, 21, 12, 12).millisecondsSinceEpoch,
  category: categoriesList.first,
  userId: 'owner',
  favoriteUsers: ['liker'],
);

Future<void> settleImages(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () async => Future<void>.delayed(const Duration(milliseconds: 500)),
  );
  await tester.pumpAndSettle();
}

Future<void> openDetails(
  WidgetTester tester,
  MemoryEvents events, {
  bool fromCard = false,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(events.changes.close);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppConfig('en', ThemeMode.light),
      child: support.LocalizedTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: fromCard
                ? Center(
                    child: EventCard(
                      eventDm: events.current!,
                      repository: events,
                    ),
                  )
                : TextButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(
                          event: events.current!,
                          repository: events,
                        ),
                      ),
                    ),
                    child: const Text('Open event'),
                  ),
          ),
        ),
      ),
    ),
  );
  await settleImages(tester);
  await tester.tap(find.text(fromCard ? events.current!.title : 'Open event'));
  await settleImages(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await AppLocalizations.delegate.load(const Locale('en'));
    await AppLocalizations.delegate.load(const Locale('ar'));
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = support.TestAuth();
  });

  testWidgets('Tapping a card opens actual event details', (tester) async {
    final events = MemoryEvents(sampleEvent());
    await openDetails(tester, events, fromCard: true);
    expect(find.byType(EventDetailsScreen), findsOneWidget);
    expect(find.text('Original event description'), findsOneWidget);
    expect(find.text('21 January'), findsOneWidget);
    expect(find.byTooltip('Edit event'), findsOneWidget);
    expect(find.byTooltip('Delete event'), findsOneWidget);
  });

  testWidgets('Editor pre-fills past date and saves the same event', (
    tester,
  ) async {
    final events = MemoryEvents(sampleEvent());
    await openDetails(tester, events);
    await tester.tap(find.byTooltip('Edit event'));
    await settleImages(tester);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      events.current!.title,
    );
    // Previously saved dates remain selectable even when they are in the past.
    final date = find.textContaining('2026');
    expect(date, findsOneWidget);
    await tester.tap(date);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      '  Updated meeting  ',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'Updated description',
    );
    await tester.drag(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListView && widget.scrollDirection == Axis.horizontal,
      ),
      const Offset(180, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book Club'));
    await settleImages(tester);
    await tester.tap(find.text('Update event'));
    await tester.pumpAndSettle();
    expect(events.updates, 1);
    expect(events.current!.id, 'event-1');
    expect(events.current!.title, 'Updated meeting');
    expect(events.current!.description, 'Updated description');
    expect(events.current!.category.id, 9);
    expect(events.current!.favoriteUsers, ['liker']);
    expect(events.current!.userId, 'owner');
    expect(events.current!.date, DateTime(2026, 1, 21).millisecondsSinceEpoch);
    expect(
      events.current!.time,
      DateTime(2026, 1, 21, 12, 12).millisecondsSinceEpoch,
    );
    expect(find.byType(ManageEventsScreen), findsNothing);
    expect(find.byType(EventDetailsScreen), findsOneWidget);
    expect(find.text('Updated meeting'), findsOneWidget);
  });

  testWidgets(
    'Failed update keeps input and prevents duplicate pending saves',
    (tester) async {
      final events = MemoryEvents(sampleEvent())..failUpdate = true;
      await openDetails(tester, events);
      await tester.tap(find.byTooltip('Edit event'));
      await settleImages(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Retry title');
      await tester.tap(find.text('Update event'));
      await tester.pumpAndSettle();
      expect(find.text('Error'), findsOneWidget);
      expect(events.current!.title, 'We are going to play football');
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text('Retry title'), findsOneWidget);
      events.failUpdate = false;
      events.pendingSave = Completer<void>();
      await tester.tap(find.text('Update event'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(events.updates, 2);
      events.pendingSave!.complete();
      await tester.pumpAndSettle();
      expect(events.current!.title, 'Retry title');
      expect(events.updates, 2);
    },
  );

  testWidgets('Delete requires confirmation and returns after deletion', (
    tester,
  ) async {
    final events = MemoryEvents(sampleEvent());
    await openDetails(tester, events);
    await tester.tap(find.byTooltip('Delete event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(events.deletes, 0);
    expect(find.byType(EventDetailsScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Delete event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete event').last);
    await tester.pumpAndSettle();
    expect(events.deletes, 1);
    expect(events.current, isNull);
    expect(find.byType(EventDetailsScreen), findsNothing);
    expect(find.text('Open event'), findsOneWidget);
  });

  testWidgets('Failed delete keeps details available for retry', (
    tester,
  ) async {
    final events = MemoryEvents(sampleEvent())..failDelete = true;
    await openDetails(tester, events);
    await tester.tap(find.byTooltip('Delete event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete event').last);
    await tester.pumpAndSettle();
    expect(events.current, isNotNull);
    expect(find.byType(EventDetailsScreen), findsOneWidget);
    expect(find.textContaining('Delete failed'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton && widget.tooltip == 'Delete event',
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('Live deletion shows an unavailable event', (tester) async {
    final events = MemoryEvents(sampleEvent());
    await openDetails(tester, events);
    events.current = null;
    events.changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('This event is no longer available.'), findsOneWidget);
    expect(find.byTooltip('Edit event'), findsNothing);
    expect(find.byTooltip('Delete event'), findsNothing);
  });
  testWidgets('Leaving the editor does not alter the original event', (
    tester,
  ) async {
    final events = MemoryEvents(sampleEvent());
    await openDetails(tester, events);
    await tester.tap(find.byTooltip('Edit event'));
    await settleImages(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Unsaved title');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(events.updates, 0);
    expect(events.current!.title, 'We are going to play football');
    expect(find.byType(EventDetailsScreen), findsOneWidget);
    expect(find.byType(ManageEventsScreen), findsNothing);
  });
}
