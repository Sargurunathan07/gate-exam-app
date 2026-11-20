import "screens/ai_coach_screen.dart";
import "screens/study_log_screen.dart";
import 'screens/dashboard_screen.dart';
import 'screens/syllabus_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GateApp());

const navy = Color(0xFF0E1729);
const card = Color(0xFF19263B);
const mint = Color(0xFF00D6A0);
const muted = Color(0xFF91A3BD);

class GateApp extends StatelessWidget {
  const GateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GATE Progress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mint,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      EditableDashboardPage(),
      InteractiveSyllabusPage(),
      InteractiveStudyLogPage(),
      AiCoachScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: selectedPage, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111D31),
        indicatorColor: const Color(0xFF24483F),
        selectedIndex: selectedPage,
        onDestinationSelected: (index) {
          setState(() => selectedPage = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Syllabus',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Study log',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI coach',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final daysLeft = DateTime(2027, 2, 7).difference(DateTime.now()).inDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'YOUR GATE STUDY SPACE',
          style: TextStyle(
            color: mint,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Steady progress.\nStronger results.',
          style: TextStyle(fontSize: 30, height: 1.15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 22),

        // Exam countdown
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF30415A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: mint, size: 19),
                  SizedBox(width: 9),
                  Text('EXAM COUNTDOWN', style: TextStyle(color: muted)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '$daysLeft',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const Text('days until your target exam date'),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF30415A)),
              const Row(
                children: [
                  Icon(Icons.event, color: mint, size: 17),
                  SizedBox(width: 8),
                  Text('7 February 2027'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Progress card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF30415A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Syllabus progress',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Text('0%', style: TextStyle(color: mint, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 13),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: 0,
                  minHeight: 10,
                  backgroundColor: Color(0xFF34445D),
                  color: mint,
                ),
              ),
              const SizedBox(height: 9),
              const Text('0 of 122 topics complete', style: TextStyle(color: muted)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('Your next steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 11),
        _NextStep(
          icon: Icons.menu_book,
          title: 'Set up your syllabus',
          subtitle: 'Choose a subject and track each topic',
          color: mint,
        ),
        const SizedBox(height: 9),
        const _NextStep(
          icon: Icons.timer_outlined,
          title: 'Log a study session',
          subtitle: 'Build a clear picture of your routine',
          color: Color(0xFF9B8CFF),
        ),
      ],
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF30415A)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: muted),
        ],
      ),
    );
  }
}

class SyllabusPage extends StatelessWidget {
  const SyllabusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      eyebrow: 'YOUR ROADMAP',
      title: 'Syllabus',
      message: 'Your subject checklist will go here.',
      icon: Icons.menu_book,
    );
  }
}

class StudyLogPage extends StatelessWidget {
  const StudyLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      eyebrow: 'BUILD YOUR ROUTINE',
      title: 'Study log',
      message: 'Your study sessions will go here.',
      icon: Icons.edit_note,
    );
  }
}

class AiCoachPage extends StatelessWidget {
  const AiCoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      eyebrow: 'PERSONAL STUDY ANALYSIS',
      title: 'AI study coach',
      message: 'Once you log study sessions, this page can help spot patterns and suggest your next step.',
      icon: Icons.auto_awesome,
    );
  }
}

class _SimplePage extends StatelessWidget {
  const _SimplePage({
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: const TextStyle(color: mint, letterSpacing: 1.4, fontSize: 11)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF30415A)),
            ),
            child: Column(
              children: [
                Icon(icon, color: mint, size: 34),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}