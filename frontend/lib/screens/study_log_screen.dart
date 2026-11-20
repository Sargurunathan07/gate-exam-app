import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_api_service.dart';

class InteractiveStudyLogPage extends StatefulWidget {
  const InteractiveStudyLogPage({super.key});

  @override
  State<InteractiveStudyLogPage> createState() =>
      _InteractiveStudyLogPageState();
}

class _InteractiveStudyLogPageState extends State<InteractiveStudyLogPage> {
  static const storageKey = 'gate_study_sessions';
  final List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(storageKey);
    if (saved == null) return;

    final decoded = jsonDecode(saved) as List<dynamic>;
    if (!mounted) return;

    setState(() {
      sessions
        ..clear()
        ..addAll(decoded.map((item) => Map<String, dynamic>.from(item)));
    });
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(sessions));

    try {
      await ProgressApiService.syncLocalProgress();
    } catch (error) {
      debugPrint('MongoDB sync failed: $error');
    }

  }

  Future<void> _addSession() async {
    final topicController = TextEditingController();
    final hoursController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add study session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: topicController,
                  decoration: const InputDecoration(
                    labelText: 'Subject or topic',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                ),
                TextField(
                  controller: hoursController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Hours studied',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    MaterialLocalizations.of(dialogContext)
                        .formatMediumDate(selectedDate),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final topic = topicController.text.trim();
                final hours = double.tryParse(hoursController.text.trim());

                if (topic.isEmpty || hours == null || hours <= 0) return;

                Navigator.pop(dialogContext, {
                  'topic': topic,
                  'hours': hours,
                  'notes': notesController.text.trim(),
                  'date': selectedDate.toIso8601String(),
                });
              },
              child: const Text('Save session'),
            ),
          ],
        ),
      ),
    );

    topicController.dispose();
    hoursController.dispose();
    notesController.dispose();

    if (result == null) return;

    setState(() => sessions.insert(0, result));
    await _saveSessions();
  }

  Future<void> _deleteSession(int index) async {
    setState(() => sessions.removeAt(index));
    await _saveSessions();
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = sessions.fold<double>(
      0,
      (total, session) => total + (session['hours'] as num).toDouble(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'BUILD YOUR ROUTINE',
          style: TextStyle(
            color: Color(0xFF00D6A0),
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Study log',
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text(
          'Notice your effort. Keep your momentum.',
          style: TextStyle(color: Color(0xFF91A3BD)),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF19263B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF30415A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.timelapse, color: Color(0xFF00D6A0), size: 28),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  'Total study time',
                  style: TextStyle(color: Color(0xFF91A3BD)),
                ),
              ),
              Text(
                '${totalHours.toStringAsFixed(1)} h',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _addSession,
          icon: const Icon(Icons.add),
          label: const Text('Add study session'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00A982),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Recent sessions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (sessions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No sessions yet. Log your first study session.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF91A3BD)),
              ),
            ),
          ),
        ...sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          final date = DateTime.parse(session['date'] as String);
          final dateText =
              MaterialLocalizations.of(context).formatMediumDate(date);
          final hours = (session['hours'] as num).toDouble();

          return Card(
            color: const Color(0xFF19263B),
            margin: const EdgeInsets.only(bottom: 9),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF24483F),
                child: Icon(Icons.menu_book, color: Color(0xFF00D6A0)),
              ),
              title: Text(session['topic'] as String),
              subtitle: Text(
                session['notes'] == ''
                    ? dateText
                    : '$dateText · ${session['notes']}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${hours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      color: Color(0xFF00D6A0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete session',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteSession(index),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
