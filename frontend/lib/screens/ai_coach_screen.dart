import 'dart:convert';

import 'package:flutter/material.dart';

import 'ai_chat_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'syllabus_screen.dart' show syllabusTopics;

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  static const sessionsKey = 'gate_study_sessions';
  static const topicsKey = 'gate_completed_topics';

  int sessionCount = 0;
  int completedCount = 0;
  double totalHours = 0;
  String nextSubject = '';
  String nextTopic = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final savedSessions = prefs.getString(sessionsKey);
    final sessions = savedSessions == null
        ? <dynamic>[]
        : jsonDecode(savedSessions) as List<dynamic>;
    final completed = prefs.getStringList(topicsKey) ?? [];

    double hours = 0;
    for (final item in sessions) {
      final session = Map<String, dynamic>.from(item as Map);
      hours += (session['hours'] as num?)?.toDouble() ?? 0;
    }

    String subjectSuggestion = '';
    String topicSuggestion = '';

    for (final subject in syllabusTopics.entries) {
      final unfinished = subject.value.where(
        (topic) => !completed.contains(topic),
      );

      if (unfinished.isNotEmpty) {
        subjectSuggestion = subject.key;
        topicSuggestion = unfinished.first.split(' — ').last;
        break;
      }
    }

    if (!mounted) return;
    setState(() {
      sessionCount = sessions.length;
      completedCount = completed.length;
      totalHours = hours;
      nextSubject = subjectSuggestion;
      nextTopic = topicSuggestion;
      loading = false;
    });
  }

  String get studyInsight {
    if (sessionCount == 0) {
      return 'Log your first study session. Then your coach can summarize your study time and suggest a next topic.';
    }

    if (totalHours < 5) {
      return 'You have logged ${totalHours.toStringAsFixed(1)} hours across $sessionCount sessions. Keep building a steady routine, then review your weekly progress.';
    }

    return 'You have logged ${totalHours.toStringAsFixed(1)} hours across $sessionCount sessions. Keep your routine steady and use your next session to move through one topic at a time.';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _analyze,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text(
            'PERSONAL STUDY ANALYSIS',
            style: TextStyle(
              color: Color(0xFF00D6A0),
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'AI study coach',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'A snapshot of your preparation so far.',
            style: TextStyle(color: Color(0xFF91A3BD)),
          ),
          const SizedBox(height: 18),

          _panel(
            icon: Icons.auto_awesome,
            title: 'Your study insight',
            child: Text(
              loading ? 'Analyzing your saved progress…' : studyInsight,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _panel(
                  icon: Icons.timelapse,
                  title: 'Study time',
                  child: Text(
                    loading ? '…' : '${totalHours.toStringAsFixed(1)} hours',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _panel(
                  icon: Icons.check_circle_outline,
                  title: 'Topics done',
                  child: Text(
                    loading ? '…' : '$completedCount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _panel(
            icon: Icons.flag_outlined,
            title: 'Suggested next topic',
            child: loading
                ? const Text('Loading your syllabus…')
                : nextTopic.isEmpty
                    ? const Text('You have checked off every topic. Great work!')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextSubject,
                            style: const TextStyle(
                              color: Color(0xFF91A3BD),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            nextTopic,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: loading ? null : _analyze,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh analysis'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chat with Gemini about GATE topics or your study plan.',
            style: TextStyle(color: Color(0xFF91A3BD), fontSize: 12),
          ),
          const SizedBox(height: 10),
          const GeminiChatBox(),
        ],
      ),
    );
  }

  Widget _panel({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF19263B),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFF30415A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00D6A0), size: 19),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
