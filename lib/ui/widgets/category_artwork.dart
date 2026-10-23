import 'package:flutter/material.dart';

class CategoryArtwork extends StatelessWidget {
  final String asset;
  const CategoryArtwork({super.key, required this.asset});

  static String assetFor(String asset, Brightness brightness) =>
      brightness == Brightness.light
      ? asset.replaceFirst('assets/categories/', 'assets/categories/light/')
      : asset;

  static Future<void> preload(
    BuildContext context,
    Iterable<String> assets,
  ) async {
    final brightness = Theme.of(context).brightness;
    for (final asset in assets) {
      if (!context.mounted) return;
      if (asset.endsWith('/Sport.png')) {
        await precacheImage(
          const AssetImage('assets/categories/sport_illustration.png'),
          context,
          onError: (error, stackTrace) {},
        );
        if (!context.mounted) return;
      }
      await precacheImage(
        AssetImage(assetFor(asset, brightness)),
        context,
        onError: (error, stackTrace) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Image.asset(
      assetFor(asset, brightness),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF101127),
          ),
          if (frame == null && !wasSynchronouslyLoaded)
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          child,
        ],
      ),
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: const Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}
