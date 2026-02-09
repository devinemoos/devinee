import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'project_storage.dart';
import 'plus_page.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  bool _checking = false;

  Future<bool> _canCreateProject() async {
    final prefs = await SharedPreferences.getInstance();
    final isPlus = prefs.getBool('isPlus') ?? false;
    if (isPlus) return true;

    final projects = await ProjectStorage.load();
    return projects.length < 3; // ✅ Free лимит
  }

  Future<void> _showLimitDialog() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Лимит Free достигнут',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'В бесплатной версии можно создать максимум 3 проекта.\n\n'
          'Перейди на PLUS, чтобы снять ограничения.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlusPage()),
              );
              setState(() {}); // обновим статус, если активировали PLUS
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B8EFF),
            ),
            child: const Text('Перейти на PLUS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<String?> _askProjectName(String lang) async {
    final ctrl = TextEditingController(text: '$lang project');

    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Новый проект: $lang', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Название проекта',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context, name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B8EFF),
            ),
            child: const Text('Создать', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    ctrl.dispose();
    return res;
  }

  Future<void> _createLanguageProject(String lang) async {
    if (_checking) return;
    setState(() => _checking = true);

    final canCreate = await _canCreateProject();
    if (!canCreate) {
      if (!mounted) return;
      setState(() => _checking = false);
      await _showLimitDialog();
      return;
    }

    if (!mounted) return;
    final name = await _askProjectName(lang);
    if (name == null) {
      setState(() => _checking = false);
      return;
    }

    final entry = ProjectEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: name,
      type: lang,
      createdAt: DateTime.now(),
    );

    await ProjectStorage.add(entry);

    if (!mounted) return;
    setState(() => _checking = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Проект создан ✅ ($lang)')),
    );

    Navigator.pop(context, true); // чтобы главная обновила список проектов
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Верхняя панель как на скрине =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Devine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.notifications, color: Colors.white, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ===== Заголовок по центру =====
              const Center(
                child: Text(
                  'Выбор языков',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ===== Кнопки языков =====
              _LangButton(
                text: 'Python',
                onTap: () => _createLanguageProject('Python'),
              ),
              _LangButton(
                text: 'C++',
                onTap: () => _createLanguageProject('C++'),
              ),
              _LangButton(
                text: 'C#',
                onTap: () => _createLanguageProject('C#'),
              ),
              _LangButton(
                text: 'JAVA',
                onTap: () => _createLanguageProject('JAVA'),
              ),

              const SizedBox(height: 18),

              // ===== Картинка снизу =====
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 340),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        // можешь заменить на свою ссылку или Image.asset(...)
                        'https://images.unsplash.com/photo-1518779578993-ec3579fee39f?auto=format&fit=crop&w=900&q=60',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.white54, size: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LangButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.black87, size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
