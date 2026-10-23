import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../models/category_dm.dart';
import 'category_artwork.dart';

class EventHeroArtwork extends StatelessWidget {
  final CategoryDm category;
  const EventHeroArtwork({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    if (category.id != 1) return CategoryArtwork(asset: category.imagePath);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF101127)
          : Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              top: constraints.maxHeight * .22,
              height: constraints.maxHeight * .55,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  l10n.categorySport,
                  style: TextStyle(
                    fontSize: 112,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              top: constraints.maxHeight * .08,
              left: constraints.maxWidth * .34,
              width: constraints.maxWidth * .36,
              height: constraints.maxHeight * .88,
              child: Image.asset(
                'assets/categories/sport_illustration.png',
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
