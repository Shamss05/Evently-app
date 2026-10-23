import '../widgets/event_hero_artwork.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/app_localizations.dart';
import '../../firebase/events_database.dart';
import '../../models/event_dm.dart';
import '../manage_events/manage_events_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventDm event;
  final EventRepository? repository;
  const EventDetailsScreen({super.key, required this.event, this.repository});
  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late EventDm _event = widget.event;
  late final EventRepository _repository =
      widget.repository ?? EventsDatabase();
  StreamSubscription<EventDm?>? _subscription;
  bool _deleting = false;
  bool _missing = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _repository
        .watchEvent(widget.event.id)
        .listen(
          (event) {
            if (!mounted || _deleting) return;
            setState(() {
              _missing = event == null;
              _loadError = null;
              if (event != null) _event = event;
            });
          },
          onError: (Object error) {
            if (mounted) setState(() => _loadError = error);
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<EventDm>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ManageEventsScreen(event: _event, repository: _repository),
      ),
    );
    if (mounted && updated != null) setState(() => _event = updated);
  }

  Future<void> _delete() async {
    if (_deleting) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteEvent),
        content: Text(l10n.deleteEventConfirmation(_event.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteEvent),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await _repository.deleteEvent(_event.id);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.eventDeletedSuccessfully)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.operationFailed(error.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final panel = theme.brightness == Brightness.dark
        ? const Color(0xFF001440)
        : Colors.white;
    final date = DateTime.fromMillisecondsSinceEpoch(_event.date);
    final time = TimeOfDay.fromDateTime(
      DateTime.fromMillisecondsSinceEpoch(_event.time),
    );
    return PopScope(
      canPop: !_deleting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.eventDetails,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            onPressed: _deleting ? null : () => Navigator.maybePop(context),
            icon: Icon(Icons.chevron_left, color: primary),
          ),
          actions: [
            if (!_missing) ...[
              IconButton(
                tooltip: l10n.editEvent,
                onPressed: _deleting ? null : _edit,
                icon: Icon(Icons.edit_outlined, size: 22, color: primary),
              ),
              IconButton(
                tooltip: l10n.deleteEvent,
                onPressed: _deleting ? null : _delete,
                icon: _deleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.delete_outline,
                        size: 22,
                        color: theme.colorScheme.error,
                      ),
              ),
            ],
            const SizedBox(width: 4),
          ],
        ),
        body: _missing
            ? Center(child: Text(l10n.eventNotFound))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  if (_loadError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Text(l10n.eventsLoadError(_loadError.toString())),
                          TextButton(
                            onPressed: _listen,
                            child: Text(l10n.tryAgain),
                          ),
                        ],
                      ),
                    ),
                  AspectRatio(
                    aspectRatio: 361 / 203,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: EventHeroArtwork(category: _event.category),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: .05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            color: primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'dd MMMM',
                                  l10n.localeName,
                                ).format(date),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time.format(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: .5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.eventDescriptionLabel,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(minHeight: 160),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _event.description,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
