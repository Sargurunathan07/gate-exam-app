import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_api_service.dart';

const syllabusTopics = <String, List<String>>{
  'General Aptitude': [
    'Verbal Aptitude — English grammar and usage',
    'Verbal Aptitude — Vocabulary',
    'Verbal Aptitude — Reading comprehension',
    'Verbal Aptitude — Sentence completion',
    'Verbal Aptitude — Sentence correction',
    'Verbal Aptitude — Logical structure of sentences',
    'Quantitative / Numerical Aptitude — Arithmetic',
    'Quantitative / Numerical Aptitude — Number systems',
    'Quantitative / Numerical Aptitude — Algebra',
    'Quantitative / Numerical Aptitude — Basic probability',
    'Quantitative / Numerical Aptitude — Statistics fundamentals',
    'Quantitative / Numerical Aptitude — Data interpretation',
    'Analytical Aptitude — Logic-based reasoning',
    'Analytical Aptitude — Analytical puzzles',
    'Analytical Aptitude — Pattern recognition',
    'Analytical Aptitude — Coding-decoding',
    'Analytical Aptitude — Analogies',
    'Analytical Aptitude — Directions and blood relations',
    'Spatial Aptitude — 2D and 3D visualization',
    'Spatial Aptitude — Mirror and water images',
    'Spatial Aptitude — Figure rotation',
    'Spatial Aptitude — Pattern matching',
    'Spatial Aptitude — Embedded figures',
    'Spatial Aptitude — Paper folding and cutting',
  ],
  'Engineering Mathematics': [
    'Discrete mathematics — Propositional and first order logic',
    'Discrete mathematics — Sets, relations, functions, partial orders and lattices',
    'Discrete mathematics — Monoids and Groups',
    'Discrete mathematics — Graphs: connectivity, matching, colouring',
    'Discrete mathematics — Combinatorics: counting, recurrence relations, generating functions',
    'Linear algebra — Matrices, determinants, system of linear equations, eigenvalues and eigenvectors, LU decomposition',
    'Calculus — Limits, continuity and differentiability, maxima and minima, mean value theorem, integration',
    'Probability and statistics — Random variables and uniform, normal, exponential, Poisson and binomial distributions',
    'Probability and statistics — Mean, median, mode and standard deviation',
    'Probability and statistics — Conditional probability and Bayes theorem',
  ],
  'Digital Logic': [
    'Logic & Minimization — Boolean algebra',
    'Logic & Minimization — Minimization',
    'Circuits — Combinational circuits',
    'Circuits — Sequential circuits',
    'Number Systems & Arithmetic — Number representations',
    'Number Systems & Arithmetic — Computer arithmetic: fixed and floating point',
  ],
  'Computer Organization and Architecture': [
    'Instructions & Addressing — Machine instructions',
    'Instructions & Addressing — Addressing modes',
    'Processor Design — ALU',
    'Processor Design — Data path',
    'Processor Design — Control unit',
    'Processor Design — Instruction pipelining',
    'Processor Design — Pipeline hazards',
    'Memory & I/O — Cache memory',
    'Memory & I/O — Main memory',
    'Memory & I/O — Secondary storage',
    'Memory & I/O — I/O interface: interrupts and DMA',
  ],
  'Programming and Data Structures': [
    'Programming — Programming in C',
    'Programming — Recursion',
    'Linear Data Structures — Arrays',
    'Linear Data Structures — Stacks',
    'Linear Data Structures — Queues',
    'Linear Data Structures — Linked lists',
    'Non-Linear Data Structures — Trees',
    'Non-Linear Data Structures — Binary search trees',
    'Non-Linear Data Structures — Binary heaps',
    'Non-Linear Data Structures — Graphs',
  ],
  'Algorithms': [
    'Fundamentals & Complexity — Searching',
    'Fundamentals & Complexity — Sorting',
    'Fundamentals & Complexity — Hashing',
    'Fundamentals & Complexity — Asymptotic worst-case time complexity',
    'Fundamentals & Complexity — Asymptotic worst-case space complexity',
    'Algorithm Design Techniques — Greedy algorithms',
    'Algorithm Design Techniques — Dynamic programming',
    'Algorithm Design Techniques — Divide and conquer',
    'Graph Algorithms — Graph traversals',
    'Graph Algorithms — Minimum spanning trees',
    'Graph Algorithms — Shortest paths',
  ],
  'Theory of Computation': [
    'Regular Languages & Automata — Regular expressions',
    'Regular Languages & Automata — Finite automata',
    'Regular Languages & Automata — Regular languages',
    'Regular Languages & Automata — Pumping lemma for regular languages',
    'Context-Free Languages & Push-Down Automata — Context-free grammars',
    'Context-Free Languages & Push-Down Automata — Push-down automata',
    'Context-Free Languages & Push-Down Automata — Context-free languages',
    'Context-Free Languages & Push-Down Automata — Pumping lemma for context-free languages',
    'Computability — Turing machines',
    'Computability — Undecidability',
  ],
  'Compiler Design': [
    'Front End — Lexical analysis',
    'Front End — Parsing',
    'Front End — Syntax-directed translation',
    'Code Generation & Runtime — Runtime environments',
    'Code Generation & Runtime — Intermediate code generation',
    'Optimization & Analysis — Local optimization',
    'Optimization & Analysis — Constant propagation',
    'Optimization & Analysis — Liveness analysis',
    'Optimization & Analysis — Common subexpression elimination',
  ],
  'Operating Systems': [
    'Processes & Concurrency — System calls',
    'Processes & Concurrency — Processes',
    'Processes & Concurrency — Threads',
    'Processes & Concurrency — Inter-process communication',
    'Processes & Concurrency — Concurrency and synchronization',
    'Deadlocks — Deadlock concepts and handling',
    'Scheduling — CPU scheduling',
    'Scheduling — I/O scheduling',
    'Memory & Storage — Memory management',
    'Memory & Storage — Virtual memory',
    'Memory & Storage — File systems',
  ],
  'Databases': [
    'Data Modeling & Query Languages — ER model',
    'Data Modeling & Query Languages — Relational algebra',
    'Data Modeling & Query Languages — Tuple calculus',
    'Data Modeling & Query Languages — SQL',
    'Database Design — Integrity constraints',
    'Database Design — Normal forms',
    'Storage, Indexing & Transactions — File organization',
    'Storage, Indexing & Transactions — Indexing',
    'Storage, Indexing & Transactions — B-trees and B+ trees',
    'Storage, Indexing & Transactions — Transactions',
    'Storage, Indexing & Transactions — Concurrency control',
  ],
  'Computer Networks': [
    'Architecture & Switching — OSI and TCP/IP protocol stacks',
    'Architecture & Switching — Packet switching',
    'Architecture & Switching — Circuit switching',
    'Architecture & Switching — Virtual circuit switching',
    'Data Link Layer — Framing',
    'Data Link Layer — Error detection',
    'Data Link Layer — Medium Access Control',
    'Data Link Layer — Ethernet bridging',
    'Network Layer — Shortest-path routing',
    'Network Layer — Flooding',
    'Network Layer — Distance-vector routing',
    'Network Layer — Link-state routing',
    'Network Layer — Fragmentation',
    'Network Layer — IP addressing',
    'Network Layer — IPv4',
    'Network Layer — CIDR notation',
    'Network Layer — ARP',
    'Network Layer — DHCP',
    'Network Layer — ICMP',
    'Network Layer — Network Address Translation',
    'Transport Layer — Flow control',
    'Transport Layer — Congestion control',
    'Transport Layer — UDP',
    'Transport Layer — TCP',
    'Transport Layer — Sockets',
    'Application Layer — DNS',
    'Application Layer — SMTP',
    'Application Layer — HTTP',
    'Application Layer — FTP',
    'Application Layer — Email',
  ],
};

class InteractiveSyllabusPage extends StatefulWidget {
  const InteractiveSyllabusPage({super.key});

  @override
  State<InteractiveSyllabusPage> createState() =>
      _InteractiveSyllabusPageState();
}

class _InteractiveSyllabusPageState extends State<InteractiveSyllabusPage> {
  static const storageKey = 'gate_completed_topics';
  final Set<String> completed = {};
  String query = '';

  int get totalTopics =>
      syllabusTopics.values.fold(0, (total, topics) => total + topics.length);

  @override
  void initState() {
    super.initState();
    _loadCompletedTopics();
  }

  Future<void> _loadCompletedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(storageKey) ?? [];
    if (!mounted) return;
    setState(() => completed.addAll(saved));

    try {
      await ProgressApiService.syncLocalProgress();
    } catch (error) {
      debugPrint('MongoDB sync failed: $error');
    }

  }

  Future<void> _toggleTopic(String topic, bool? checked) async {
    setState(() {
      if (checked == true) {
        completed.add(topic);
      } else {
        completed.remove(topic);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storageKey, completed.toList());

    try {
      await ProgressApiService.syncLocalProgress();
    } catch (error) {
      debugPrint('MongoDB sync failed: $error');
    }

  }

  List<Widget> _buildGroupedTopics(List<String> items) {
    final groups = <String, List<String>>{};

    for (final item in items) {
      final parts = item.split(' — ');
      final group = parts.first;
      groups.putIfAbsent(group, () => []).add(item);
    }

    return groups.entries.map((group) {
      final finished = group.value.where(completed.contains).length;

      return ExpansionTile(
        title: Text(group.key),
        subtitle: Text('$finished of ${group.value.length} topics'),
        children: group.value.map((item) {
          final parts = item.split(' — ');
          final label = parts.skip(1).join(' — ');

          return CheckboxListTile(
            value: completed.contains(item),
            activeColor: const Color(0xFF00D6A0),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(label),
            onChanged: (checked) => _toggleTopic(item, checked),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleSubjects = syllabusTopics.entries.where((subject) {
      final search = query.toLowerCase();
      return subject.key.toLowerCase().contains(search) ||
          subject.value.any((topic) => topic.toLowerCase().contains(search));
    }).toList();

    final progress = totalTopics == 0 ? 0.0 : completed.length / totalTopics;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'YOUR ROADMAP',
          style: TextStyle(
            color: Color(0xFF00D6A0),
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Syllabus',
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text(
          'Check a topic when you finish it.',
          style: TextStyle(color: Color(0xFF91A3BD)),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFF19263B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF30415A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Topics completed',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF00D6A0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: const Color(0xFF34445D),
                color: const Color(0xFF00D6A0),
              ),
              const SizedBox(height: 8),
              Text(
                '${completed.length} of $totalTopics topics complete',
                style: const TextStyle(
                  color: Color(0xFF91A3BD),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          onChanged: (value) => setState(() => query = value.trim()),
          decoration: InputDecoration(
            hintText: 'Search subjects or topics',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFF19263B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF30415A)),
            ),
          ),
        ),
        const SizedBox(height: 13),
        ...visibleSubjects.map((subject) {
          final finished = subject.value.where(completed.contains).length;

          return Card(
            color: const Color(0xFF19263B),
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
              side: const BorderSide(color: Color(0xFF30415A)),
            ),
            child: ExpansionTile(
              title: Text(
                subject.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '$finished of ${subject.value.length} topics',
                style: const TextStyle(
                  color: Color(0xFF91A3BD),
                  fontSize: 12,
                ),
              ),
              children: _buildGroupedTopics(subject.value),
            ),
          );
        }),
      ],
    );
  }
}
