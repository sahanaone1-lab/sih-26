import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/clinical_intake_model.dart';
import '../../models/patient_model.dart';
import '../../services/clinical_intake_service.dart';
import 'clinical_history_summary_screen.dart';

/// Screen 4: Medical History Timeline
///
/// Displays a structured chronological timeline aggregating data from AI conversation,
/// voice-to-text notes, OCR-scanned prescriptions/lab reports, and ABDM health records.
class MedicalHistoryTimelineScreen extends StatefulWidget {
  final PatientModel patient;

  const MedicalHistoryTimelineScreen({super.key, required this.patient});

  @override
  State<MedicalHistoryTimelineScreen> createState() =>
      _MedicalHistoryTimelineScreenState();
}

class _MedicalHistoryTimelineScreenState
    extends State<MedicalHistoryTimelineScreen> {
  final _service = ClinicalIntakeService.instance;
  late List<TimelineEvent> _allEvents;
  TimelineCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _allEvents = _service.getMedicalHistoryTimeline(widget.patient);
  }

  List<TimelineEvent> get _filteredEvents {
    if (_filterCategory == null) return _allEvents;
    return _allEvents.where((e) => e.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        shadowColor: AppColors.cardShadow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Medical History Timeline',
          style: TextStyle(
            color: AppColors.navyPrimary,
            fontSize: 16.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'View Clinical Summary',
            icon: const Icon(Icons.assignment_rounded, color: AppColors.saffronDark),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ClinicalHistorySummaryScreen(patient: widget.patient),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timeline Intro Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              color: AppColors.background,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.hub_rounded,
                        color: AppColors.greenSuccess, size: 20.0),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Unified Patient Journey',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        SizedBox(height: 2.0),
                        Text(
                          'Chronological synthesis of AI intake, voice notes, and OCR documents.',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, color: AppColors.divider),

            // Category Filter Chips
            Container(
              height: 48.0,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildFilterChip('All Events', null),
                  const SizedBox(width: 8.0),
                  _buildFilterChip('Voice History', TimelineCategory.voiceNarration),
                  const SizedBox(width: 8.0),
                  _buildFilterChip('Medications', TimelineCategory.medication),
                  const SizedBox(width: 8.0),
                  _buildFilterChip('Lab Reports', TimelineCategory.labReport),
                  const SizedBox(width: 8.0),
                  _buildFilterChip('Consultations', TimelineCategory.hospitalVisit),
                ],
              ),
            ),

            // Timeline List View
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.event_busy_rounded,
                              size: 40.0, color: AppColors.textMuted),
                          SizedBox(height: 10.0),
                          Text('No timeline events in this category.',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16.0),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final isLast = index == events.length - 1;
                        return _buildTimelineItem(event, isLast);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TimelineCategory? category) {
    final isSelected = _filterCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.greenSuccess,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.navyPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 11.5,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.greenSuccess : AppColors.surfaceBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      onSelected: (selected) {
        setState(() {
          _filterCategory = selected ? category : null;
        });
      },
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left timestamp column
          SizedBox(
            width: 70.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${event.date.day} ${_monthName(event.date.month)}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyPrimary,
                    ),
                  ),
                  Text(
                    '${event.date.year}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Timeline vertical line & icon dot
          Column(
            children: [
              Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  color: event.category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: event.category.color, width: 1.5),
                ),
                child: Icon(event.category.icon,
                    size: 14.0, color: event.category.color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: AppColors.surfaceBorder,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12.0),

          // Event Card Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18.0),
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: AppColors.surfaceBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(
                          event.sourceTag,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    event.summary,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  if (event.details.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    ...event.details.map((detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Row(
                            children: [
                              Container(
                                width: 4.0,
                                height: 4.0,
                                decoration: const BoxDecoration(
                                  color: AppColors.saffronPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Expanded(
                                child: Text(
                                  detail,
                                  style: const TextStyle(
                                    fontSize: 11.0,
                                    color: AppColors.navyLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
