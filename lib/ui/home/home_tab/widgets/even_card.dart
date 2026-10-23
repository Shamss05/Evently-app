import '../../../event_details/event_details_screen.dart';
import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:assignment_6/firebase/events_database.dart';
import 'package:assignment_6/firebase/firebase_auth_service.dart';
import 'package:assignment_6/models/event_dm.dart';
import '../../../widgets/category_artwork.dart';

class EventCard extends StatelessWidget {
  final EventDm eventDm;
  final EventRepository? repository;
  const EventCard({required this.eventDm, super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final panel = dark ? const Color(0xFF001440) : const Color(0xFFF4F7FF);
    final border = dark ? const Color(0xFF002D8F) : const Color(0xFFEEEEEE);
    final favorite = eventDm.favoriteUsers.contains(
      FirebaseAuthService().getUserData()?.uid,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EventDetailsScreen(event: eventDm, repository: repository),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 361 / 203,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF101127) : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (eventDm.category.id == 3)
                LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 8,
                        height: constraints.maxHeight * .50,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                          child: Text(
                            l10n.categoryMeeting,
                            style: TextStyle(
                              fontSize: 96,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * .28,
                        left: constraints.maxWidth * .30,
                        width: constraints.maxWidth * .44,
                        height: constraints.maxHeight * .74,
                        child: Image.asset(
                          'assets/categories/meeting_illustration.png',
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
                    ],
                  ),
                )
              else
                CategoryArtwork(asset: eventDm.category.imagePath),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    DateFormat(
                      'dd MMM',
                      l10n.localeName,
                    ).format(DateTime.fromMillisecondsSinceEpoch(eventDm.date)),
                    style: TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 66,
                child: ColoredBox(
                  color: dark ? const Color(0xFF101127) : Colors.white,
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58),
                  padding: const EdgeInsetsDirectional.only(
                    start: 8,
                    end: 2,
                    top: 6,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          eventDm.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: dark
                                ? Colors.white
                                : const Color(0xFF1C1C1C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: favorite
                            ? l10n.removeFromFavorites
                            : l10n.addToFavorites,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: const EdgeInsets.all(8),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          favorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          size: 24,
                          color: primary,
                        ),
                        onPressed: () async {
                          try {
                            await onFavoritePress();
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.operationFailed(error.toString()),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onFavoritePress() async {
    await EventsDatabase().updateEventLike(
      FirebaseAuthService().getUserData()?.uid ?? '',
      eventDm,
    );
  }
}
