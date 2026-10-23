import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:assignment_6/firebase/events_database.dart';
import 'package:assignment_6/models/category_dm.dart';
import 'package:assignment_6/ui/home/home_tab/widgets/even_card.dart';
import 'package:assignment_6/ui/home/home_tab/widgets/home_header.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<CategoryDm> categories = [];
  late CategoryDm selectedCategory;

  final EventsDatabase database = EventsDatabase();
  late final eventsStream = database.getEventsStream();

  @override
  void initState() {
    super.initState();
    categories.add(CategoryDm(-1, "", Icons.border_all_rounded));
    categories.addAll(categoriesList);
    selectedCategory = categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeHeader(
          categoriesList: categories,
          selectedCategory: selectedCategory,
          changeSelectedCategory: changeSelectedCategory,
        ),
        StreamBuilder(
          stream: eventsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Expanded(
                child: Center(
                  child: Text(l10n.eventsLoadError(snapshot.error.toString())),
                ),
              );
            } else if (snapshot.hasData) {
              var events =
                  snapshot.data?.docs
                      .map((e) => e.data())
                      .where(
                        (event) =>
                            selectedCategory.id == -1 ||
                            event.category.id == selectedCategory.id,
                      )
                      .toList() ??
                  [];
              if (events.isEmpty) {
                return Expanded(
                  child: Center(child: Text(l10n.noEventsInCategory)),
                );
              }
              return Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 88),
                  separatorBuilder: (_, _) => SizedBox(height: 16),
                  itemBuilder: (_, index) => EventCard(eventDm: events[index]),
                  itemCount: events.length,
                ),
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ],
    );
  }

  void changeSelectedCategory(CategoryDm category) {
    setState(() {
      selectedCategory = category;
    });
  }
}
