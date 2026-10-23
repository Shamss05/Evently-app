import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../firebase/events_database.dart';
import '../../../firebase/firebase_auth_service.dart';
import '../home_tab/widgets/even_card.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});
  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final database = EventsDatabase();
  String search = '';
  late final favorites = database.getFavoriteStream(
    FirebaseAuthService().getUserData()?.uid ?? '',
  );
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => search = value.trim().toLowerCase()),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE6E9F0)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: l10n.searchForEvent,
                suffixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF0E3A99),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: favorites,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.eventsLoadError(snapshot.error.toString()),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events =
                    snapshot.data!.docs
                        .map((doc) => doc.data())
                        .where(
                          (event) =>
                              event.title.toLowerCase().contains(search) ||
                              event.description.toLowerCase().contains(search),
                        )
                        .toList()
                      ..sort((a, b) => a.time.compareTo(b.time));
                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      search.isEmpty
                          ? l10n.noFavoritesYet
                          : l10n.noMatchingEvents,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: events.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (_, index) => EventCard(eventDm: events[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
