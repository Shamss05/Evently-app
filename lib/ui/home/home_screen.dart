import 'package:assignment_6/core/l10n/app_localizations.dart';
import '../widgets/category_artwork.dart';
import '../../models/category_dm.dart';
import 'package:flutter/material.dart';
import '../manage_events/manage_events_screen.dart';
import 'home_tab/home_tab.dart';
import 'favorite_tab/favorite_tab.dart';
import 'profile_tab/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  Brightness? _preloadedBrightness;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_preloadedBrightness != brightness) {
      _preloadedBrightness = brightness;
      CategoryArtwork.preload(context, [
        categoriesList.last.imagePath,
        ...categoriesList
            .take(categoriesList.length - 1)
            .map((category) => category.imagePath),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [HomeTab(), FavoriteTab(), ProfileTab()],
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: l10n.addEventTitle,
        onPressed: () =>
            Navigator.pushNamed(context, ManageEventsScreen.routeName),
        elevation: 3,
        child: const Icon(Icons.add, size: 22),
      ),
      bottomNavigationBar: HomeNavigation(
        selectedIndex: selectedIndex,
        onChanged: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

class HomeNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const HomeNavigation({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        ),
        BottomNavigationBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : Colors.white,
          elevation: 0,
          iconSize: 22,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: onChanged,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              activeIcon: const Icon(Icons.favorite),
              label: l10n.favorite,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Center(
                  child: Container(
                    width: 42,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
