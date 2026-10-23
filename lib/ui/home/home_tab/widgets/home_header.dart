import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../firebase/firebase_auth_service.dart';
import '../../../../models/category_dm.dart';

class HomeHeader extends StatelessWidget {
  final List<CategoryDm> categoriesList;
  final CategoryDm selectedCategory;
  final ValueChanged<CategoryDm> changeSelectedCategory;
  const HomeHeader({
    super.key,
    required this.categoriesList,
    required this.selectedCategory,
    required this.changeSelectedCategory,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = context.watch<AppConfig>();
    final primary = Theme.of(context).colorScheme.primary;
    final user = FirebaseAuthService().getUserData();
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeBack,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF686868),
                        ),
                      ),
                      Text(
                        user?.displayName ??
                            user?.email?.split('@').first ??
                            '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.changeTheme,
                  onPressed: () => config.changeTheme(
                    config.isDark() ? ThemeMode.light : ThemeMode.dark,
                  ),
                  icon: Icon(
                    config.isDark()
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: primary,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      config.changeLocale(config.isEn() ? 'ar' : 'en'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.languageCodeLabel),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoriesList
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: category.id == selectedCategory.id
                                ? primary
                                : const Color(0xFFE6E9F0),
                          ),
                          backgroundColor: config.isDark()
                              ? Theme.of(context).colorScheme.surface
                              : Colors.white,
                          selected: category.id == selectedCategory.id,
                          showCheckmark: false,
                          selectedColor: primary,
                          avatar: Icon(
                            category.icon,
                            size: 16,
                            color: category.id == selectedCategory.id
                                ? Colors.white
                                : primary,
                          ),
                          label: Text(l10n.categoryName(category.id)),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: category.id == selectedCategory.id
                                ? Colors.white
                                : primary,
                          ),
                          onSelected: (_) => changeSelectedCategory(category),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
