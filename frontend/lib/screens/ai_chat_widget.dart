import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'syllabus_screen.dart' show syllabusTopics;
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

class GeminiChatBox extends StatefulWidget {
  const GeminiChatBox({super.key});

  @override
  State<GeminiChatBox> createState() => _GeminiChatBoxState();
}

class _GeminiChatBoxState extends State<GeminiChatBox> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final messages = <Map<String, String>>[];
  bool sending = false;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<String> _loadStudyContext() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTopics = prefs.getStringList('gate_completed_topics') ?? [];
    final allTopics = syllabusTopics.values.expand((topics) => topics).toSet();
    final completedCount = savedTopics.where(allTopics.contains).length;
    final totalTopics = allTopics.length;

    final savedSessions = prefs.getString('gate_study_sessions');
    final sessions = savedSessions == null
        ? <dynamic>[]
        : jsonDecode(savedSessions) as List<dynamic>;

    final totalHours = sessions.fold<double>(0, (sum, item) {
      final session = Map<String, dynamic>.from(item as Map);
      return sum + ((session['hours'] as num?)?.toDouble() ?? 0);
    });

    final subjectProgress = syllabusTopics.entries.map((subject) {
      final done = subject.value.where(savedTopics.contains).length;
      return '- ${subject.key}: $done of ${subject.value.length} topics';
    }).join('\\n');

    final recentSessions = sessions.take(5).map((item) {
      final session = Map<String, dynamic>.from(item as Map);
      final hours = (session['hours'] as num?)?.toDouble() ?? 0;
      return '- ${session['topic']}: ${hours.toStringAsFixed(1)} hours';
    }).join('\\n');

    return '''
Syllabus completion: $completedCount of $totalTopics topics.
Study time logged: ${totalHours.toStringAsFixed(1)} hours across ${sessions.length} sessions.
Progress by subject:
$subjectProgress
Recent study sessions:
${recentSessions.isEmpty ? 'No study sessions logged yet.' : recentSessions}
''';
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty || sending) return;

    final previousMessages = messages
        .map((message) => {
              'role': message['role']!,
              'text': message['text']!,
            })
        .toList();

    setState(() {
      messages.add({'role': 'user', 'text': text});
      sending = true;
    });
    controller.clear();
    _scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': text,
              'history': previousMessages,
              'studyContext': await _loadStudyContext(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['reply'] is String) {
        setState(() {
          messages.add({'role': 'assistant', 'text': data['reply'] as String});
        });
      } else {
        throw Exception(data['error'] ?? 'The server could not answer.');
      }
    } catch (error) {
      setState(() {
        messages.add({
          'role': 'assistant',
          'text': 'Request failed: $error',
        });
      });
    } finally {
      if (mounted) setState(() => sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF19263B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30415A)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF00D6A0)),
              SizedBox(width: 9),
              Text(
                'Ask Gemini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Ask about a GATE topic or your study plan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF91A3BD)),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: messages.length + (sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (sending && index == messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final message = messages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF176B58)
                                : const Color(0xFF26364D),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(message['text']!),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Type your question…',
                    filled: true,
                    fillColor: const Color(0xFF101B2D),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: sending ? null : _send,
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF00A982),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
