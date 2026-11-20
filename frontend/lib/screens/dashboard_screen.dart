import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'syllabus_screen.dart' show syllabusTopics;

class EditableDashboardPage extends StatefulWidget {
  const EditableDashboardPage({super.key});

  @override
  State<EditableDashboardPage> createState() =>
      _EditableDashboardPageState();
}

class _EditableDashboardPageState extends State<EditableDashboardPage> {
  static const dateKey = 'gate_exam_date';
  static const topicsKey = 'gate_completed_topics';

  DateTime examDate = DateTime(2027, 2, 7);
  int completedTopics = 0;
  bool loading = true;

  int get totalTopics =>
      syllabusTopics.values.fold(0, (sum, topics) => sum + topics.length);

  double get progress =>
      totalTopics == 0 ? 0 : completedTopics / totalTopics;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(dateKey);
    final savedTopics = prefs.getStringList(topicsKey) ?? [];

    if (!mounted) return;
    setState(() {
      if (savedDate != null) {
        examDate = DateTime.tryParse(savedDate) ?? examDate;
      }
      completedTopics = savedTopics.length;
      loading = false;
    });
  }

  Future<void> _chooseExamDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: examDate.isBefore(today) ? today : examDate,
      firstDate: today,
      lastDate: DateTime(2035),
      helpText: 'Choose your GATE exam date',
    );

    if (selected == null) return;

    setState(() => examDate = selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dateKey, selected.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = examDate.difference(DateTime.now()).inDays;
    final dateLabel =
        MaterialLocalizations.of(context).formatMediumDate(examDate);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text(
            'YOUR GATE STUDY SPACE',
            style: TextStyle(
              color: Color(0xFF00D6A0),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Steady progress.\nStronger results.',
            style: TextStyle(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),

          // Exam date card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF00D6A0),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'EXAM DATE',
                        style: TextStyle(color: Color(0xFF91A3BD)),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _chooseExamDate,
                      icon: const Icon(Icons.edit_calendar, size: 17),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysLeft >= 0 ? '$daysLeft days left' : 'Choose a future date',
                  style: const TextStyle(color: Color(0xFF00D6A0)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Live syllabus progress from saved checkboxes
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Syllabus progress',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      loading ? '…' : '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Color(0xFF00D6A0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                LinearProgressIndicator(
                  value: loading ? null : progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: const Color(0xFF34445D),
                  color: const Color(0xFF00D6A0),
                ),
                const SizedBox(height: 9),
                Text(
                  loading
                      ? 'Loading your progress…'
                      : '$completedTopics of $totalTopics topics complete',
                  style: const TextStyle(color: Color(0xFF91A3BD)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pull down to refresh after updating your syllabus.',
                  style: TextStyle(color: Color(0xFF71839C), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF19263B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF30415A)),
      ),
      child: child,
    );
  }
}
