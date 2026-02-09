import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nprjct.dart';
import 'ip_service.dart';
import 'advice_service.dart';
import 'main.dart';
import 'plus_page.dart';
import 'profile_page.dart';
import 'about_page.dart';
import 'project_storage.dart';
import 'ai_assistant_page.dart';
import 'constructor_page.dart';
import 'api_tester_page.dart';
import 'notification_service.dart';
import 'python_editor_page.dart'; // ✅ добавили

class GlavPage extends StatefulWidget {
  const GlavPage({super.key});

  @override
  State<GlavPage> createState() => _GlavPageState();
}

class _GlavPageState extends State<GlavPage> {
  late Future<Map<String, dynamic>?> _ipDataFuture;
  late Future<String?> _adviceFuture;
  late Future<List<ProjectEntry>> _projectsFuture;

  int _navIndex = 0;
  bool _isPlus = false;

  static const int freeLimit = 3;

  @override
  void initState() {
    super.initState();
    _ipDataFuture = IpService.fetchIpInfo();
    _adviceFuture = AdviceService.fetchAdvice();
    _projectsFuture = ProjectStorage.load();
    _loadPlus();
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _projectsFuture = ProjectStorage.load();
    });
  }

  Future<void> _loadPlus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPlus = prefs.getBool('isPlus') ?? false;
    });
  }

  Future<void> _logoutToStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StartScreen()),
      (route) => false,
    );
  }

  Future<void> _openPlus() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlusPage()),
    );
    await _loadPlus();
    await _refreshProjects();
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutPage()),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      ).then((_) async {
        await _loadPlus();
        await _refreshProjects();
      });
    }
  }

  Future<void> _openNewProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewProjectPage()),
    );
    if (result == true) await _refreshProjects();
  }

  Future<void> _openAiAssistant() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiAssistantPage()),
    );
    await _loadPlus();
  }

  Future<void> _openConstructor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConstructorPage()),
    );
    if (result == true) await _refreshProjects();
  }

  Future<void> _openApiTester() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ApiTesterPage()),
    );
  }

  Future<void> _deleteProject(String id) async {
    await ProjectStorage.removeById(id);
    await _refreshProjects();
  }

  void _showProjectDetails(ProjectEntry p) {
    // ✅ если Python — открываем редактор кода
    if (p.type == 'Python') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PythonEditorPage(project: p),
        ),
      );
      return;
    }

    // остальные типы — как было: диалог
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(p.title, style: const TextStyle(color: Colors.white)),
        content: Text(
          'Тип: ${p.type}\nСоздан: ${_fmtDate(p.createdAt)}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ок', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _navIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TOP BAR =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _logoutToStart,
                      child: const Text(
                        'Devine',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (!_isPlus)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _openPlus,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9B8EFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.star, color: Colors.white, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'PLUS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!_isPlus) const SizedBox(width: 10),

                        // ✅ уведомление по нажатию (как было)
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await NotificationService.show(
                              title: 'Devine',
                              body: 'Локальные уведомления работают 🔔',
                            );
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.notifications, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Ваши проекты',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // ===== LIMIT STATUS =====
                FutureBuilder<List<ProjectEntry>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    final count = (snapshot.data ?? []).length;
                    if (_isPlus) return _statusChip('PLUS активен ✅ Безлимит');
                    final left = (freeLimit - count).clamp(0, freeLimit);
                    return _statusChip('Free: осталось проектов $left из $freeLimit');
                  },
                ),

                const SizedBox(height: 14),

                // ===== PROJECT LIST =====
                FutureBuilder<List<ProjectEntry>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return _loadingCard();
                    }

                    final projects = snapshot.data ?? [];

                    if (projects.isEmpty) {
                      return _emptyProjectsCard();
                    }

                    return Column(
                      children: projects.map((p) => _projectCard(p)).toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ===== IP CARD =====
                FutureBuilder<Map<String, dynamic>?>(
                  future: _ipDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _loadingCard();
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return _errorCard('Не удалось получить IP');
                    } else {
                      final data = snapshot.data!;
                      return _infoCard(
                        icon: Icons.public,
                        title: 'IP: ${data['ip']}',
                        lines: [
                          'Страна: ${data['country_name']}',
                          'Город: ${data['city']}',
                          'Регион: ${data['region_name']}',
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // ===== ADVICE =====
                FutureBuilder<String?>(
                  future: _adviceFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _loadingCard();
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return _errorCard('Не удалось получить совет');
                    } else {
                      return _infoCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Совет дня',
                        lines: [snapshot.data!],
                      );
                    }
                  },
                ),

                const SizedBox(height: 30),

                // ===== BUTTONS =====
                ProjectButton(
                  icon: Icons.add,
                  text: 'Новый проект',
                  onTap: _openNewProject,
                ),
                ProjectButton(
                  icon: Icons.smart_toy,
                  text: 'ИИ Ассистент',
                  onTap: _openAiAssistant,
                ),
                ProjectButton(
                  icon: Icons.code,
                  text: 'Конструктор',
                  onTap: _openConstructor,
                ),
                ProjectButton(
                  icon: Icons.data_object,
                  text: 'API тестер',
                  onTap: _openApiTester,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== UI helpers =====

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _emptyProjectsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Пока нет проектов.\nНажми “Новый проект”, чтобы создать первый ✅',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _projectCard(ProjectEntry p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showProjectDetails(p),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.folder_open, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.type} • ${_fmtDate(p.createdAt)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteProject(p.id),
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _errorCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required List<String> lines,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ...lines.map(
                  (e) => Text(
                    e,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const ProjectButton({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
