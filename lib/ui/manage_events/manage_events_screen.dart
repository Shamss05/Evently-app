import '../widgets/event_hero_artwork.dart';
import 'package:assignment_6/core/l10n/app_localizations.dart';
import '../widgets/category_artwork.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/app_dialogs_utils.dart';
import '../../core/utils/data_validator.dart';
import '../../core/utils/date_extention.dart';
import '../../firebase/events_database.dart';
import '../../models/category_dm.dart';
import '../../models/event_dm.dart';

class ManageEventsScreen extends StatefulWidget {
  static const String routeName = "/manage-events";

  final EventDm? event;
  final EventRepository? repository;
  const ManageEventsScreen({super.key, this.event, this.repository});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final eventCategories = [
    categoriesList.last,
    ...categoriesList.take(categoriesList.length - 1),
  ];
  late CategoryDm selectedCategory = eventCategories.first;
  late final ScrollController _categoryScrollController = ScrollController(
    initialScrollOffset: _isEditing
        ? eventCategories.indexWhere(
                (category) => category.id == selectedCategory.id,
              ) *
              92.0
        : 0,
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSaving = false;
  Brightness? _preloadedBrightness;
  bool get _isEditing => widget.event != null;
  late final EventRepository _repository =
      widget.repository ?? EventsDatabase();

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    if (event != null) {
      selectedCategory = event.category;
      titleController.text = event.title;
      descriptionController.text = event.description;
      selectedDate = DateTime.fromMillisecondsSinceEpoch(event.date).dateOnly;
      selectedTime = TimeOfDay.fromDateTime(
        DateTime.fromMillisecondsSinceEpoch(event.time),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_preloadedBrightness != brightness) {
      _preloadedBrightness = brightness;
      CategoryArtwork.preload(
        context,
        eventCategories.map((category) => category.imagePath),
      );
    }
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final inputColor = config.isDark() ? const Color(0xFF001440) : Colors.white;
    InputDecoration field(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF909090)),
      filled: true,
      fillColor: inputColor,
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? l10n.editEvent : l10n.addEventTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: primary),
            onPressed: _isSaving ? null : () => Navigator.maybePop(context),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isSaving ? null : _saveEvent,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? l10n.updateEvent : l10n.addEvent),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Form(
            key: formKey,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 361 / 203,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: EventHeroArtwork(category: selectedCategory),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            controller: _categoryScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: eventCategories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              final category = eventCategories[index];
                              final selected =
                                  category.id == selectedCategory.id;
                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () =>
                                    setState(() => selectedCategory = category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected ? primary : inputColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? primary
                                          : const Color(0xFFE6E9F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category.icon,
                                        size: 16,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF8B8B8B),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.categoryName(category.id),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: selected
                                              ? Colors.white
                                              : const Color(0xFF686868),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.eventTitleLabel,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: titleController,
                          style: const TextStyle(fontSize: 14),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (input) =>
                              DataValidator.titleValidation(input, l10n),
                          decoration: field(l10n.eventTitleHint),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.eventDescriptionLabel,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 150),
                            child: TextFormField(
                              controller: descriptionController,
                              textAlignVertical: TextAlignVertical.top,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(fontSize: 14),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (input) =>
                                  DataValidator.descriptionValidation(
                                    input,
                                    l10n,
                                  ),
                              decoration: field(l10n.eventDescriptionHint),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.eventDate,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => getEventDate(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  selectedDate == null
                                      ? (l10n.chooseDate)
                                      : (_isEditing
                                                ? DateFormat.yMMMd(
                                                    l10n.localeName,
                                                  )
                                                : DateFormat(
                                                    'dd-MM-yyyy',
                                                    l10n.localeName,
                                                  ))
                                            .format(selectedDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: _isEditing
                                        ? TextDecoration.underline
                                        : null,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 18, color: primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.eventTime,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => selectTime(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  selectedTime == null
                                      ? (l10n.chooseTime)
                                      : selectedTime!.format(context),
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: _isEditing
                                        ? TextDecoration.underline
                                        : null,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    final isFormValid = formKey.currentState?.validate() ?? false;
    String errorMessage = "";
    if (selectedTime == null) {
      errorMessage += "\n- ${l10n.selectEventTime}";
    }
    if (selectedDate == null) {
      errorMessage += "\n- ${l10n.selectEventDate}";
    }
    if (!isFormValid) {
      if (titleController.text.trim().isEmpty) {
        errorMessage += "\n- ${l10n.enterEventTitle}";
      }
      if (descriptionController.text.trim().isEmpty) {
        errorMessage += "\n- ${l10n.enterEventDescription}";
      }
    }

    if (errorMessage.isNotEmpty || !isFormValid) {
      if (errorMessage.isNotEmpty) {
        AppDialogsUtils.showActionDialog(
          context: context,
          title: l10n.invalidData,
          content: errorMessage,
          posActionTitle: l10n.tryAgain,
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      final eventDate = selectedDate!.dateOnly;
      final eventTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      final original = widget.event;
      final event = EventDm(
        id: original?.id ?? '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: eventDate.millisecondsSinceEpoch,
        time: eventTime.millisecondsSinceEpoch,
        category: selectedCategory,
        favoriteUsers: List<String>.of(original?.favoriteUsers ?? []),
        userId: original?.userId ?? '',
      );
      if (_isEditing) {
        await _repository.updateEvent(event);
      } else {
        await _repository.createEvent(event);
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, event);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? l10n.eventUpdatedSuccessfully
                : l10n.eventCreatedSuccessfully,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppDialogsUtils.showActionDialog(
        context: context,
        title: l10n.error,
        content: l10n.operationFailed(error.toString()),
        posActionTitle: l10n.tryAgain,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    var time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (!mounted) return;
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  Future<void> getEventDate(BuildContext context) async {
    final today = DateTime.now().dateOnly;
    final initialDate = selectedDate ?? today;
    final firstDate = initialDate.isBefore(today) ? initialDate : today;
    final defaultLastDate = today.add(const Duration(days: 365));
    final lastDate = initialDate.isAfter(defaultLastDate)
        ? initialDate
        : defaultLastDate;
    var date = await showDatePicker(
      context: context,
      firstDate: firstDate,
      initialDate: initialDate,
      lastDate: lastDate,
    );
    if (!mounted) return;
    if (date != null) {
      setState(() {
        selectedDate = date.dateOnly;
      });
    }
  }
}
