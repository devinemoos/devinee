import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'project_storage.dart';

class ConstructorPage extends StatefulWidget {
  const ConstructorPage({super.key});

  @override
  State<ConstructorPage> createState() => _ConstructorPageState();
}

class _ConstructorPageState extends State<ConstructorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  String _template = 'Flutter Starter';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<String> _getTemplateFiles(String template) {
    switch (template) {
      case 'Flutter Starter':
        return [
          'lib/main.dart',
          'lib/glav.dart',
          'lib/register_page.dart',
          'lib/profile_page.dart',
          'lib/about_page.dart',
          'lib/plus_page.dart',
          'lib/ai_assistant_page.dart',
          'lib/project_storage.dart',
          'lib/constructor_page.dart',
          'pubspec.yaml',
          'README.md',
        ];

      case 'Flutter + API (HTTP)':
        return [
          'lib/main.dart',
          'lib/services/api_service.dart',
          'lib/models/response_model.dart',
          'lib/pages/home_page.dart',
          'lib/pages/api_tester_page.dart',
          'lib/widgets/json_view.dart',
          'pubspec.yaml',
          'README.md',
        ];

      case 'Web (HTML/CSS/JS)':
        return [
          'index.html',
          'assets/css/style.css',
          'assets/js/app.js',
          'assets/img/',
          'README.md',
        ];

      case 'Python FastAPI':
        return [
          'app/main.py',
          'app/routers/',
          'app/schemas/',
          'app/services/',
          'requirements.txt',
          'README.md',
        ];

      default:
        return ['README.md'];
    }
  }

  String _getTemplateDescription(String template) {
    switch (template) {
      case 'Flutter Starter':
        return 'Базовый шаблон Flutter приложения: стартовый экран, регистрация, главная, профиль, PLUS.';
      case 'Flutter + API (HTTP)':
        return 'Шаблон под работу с API: сервисы, модели, экран тестера запросов.';
      case 'Web (HTML/CSS/JS)':
        return 'Лёгкий шаблон сайта: чистый HTML + CSS + JS.';
      case 'Python FastAPI':
        return 'Шаблон backend API на FastAPI: роуты, схемы, сервисы.';
      default:
        return '';
    }
  }

  Future<void> _saveProject() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final title = _nameCtrl.text.trim();
    final files = _getTemplateFiles(_template);

    // 1) Сохраняем как "проект" в общий список
    final entry = ProjectEntry(
      id: id,
      title: title,
      type: 'Конструктор: $_template',
      createdAt: DateTime.now(),
    );
    await ProjectStorage.add(entry);

    // 2) Сохраняем структуру файлов отдельно (чтобы потом можно было открыть)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('project_${id}_files', jsonEncode(files));
    await prefs.setString('project_${id}_template', _template);

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Проект создан ✅ (структура сохранена)')),
    );

    Navigator.pop(context, true); // чтобы главная обновила список проектов
  }

  @override
  Widget build(BuildContext context) {
    final files = _getTemplateFiles(_template);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Конструктор', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Создай проект из шаблона',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getTemplateDescription(_template),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 18),

                // Название
                TextFormField(
                  controller: _nameCtrl,
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
                    errorStyle: const TextStyle(color: Colors.redAccent),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Введите название';
                    if (s.length < 3) return 'Минимум 3 символа';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Шаблон
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.grey[900],
                      value: _template,
                      iconEnabledColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: 'Flutter Starter',
                          child: Text('Flutter Starter'),
                        ),
                        DropdownMenuItem(
                          value: 'Flutter + API (HTTP)',
                          child: Text('Flutter + API (HTTP)'),
                        ),
                        DropdownMenuItem(
                          value: 'Web (HTML/CSS/JS)',
                          child: Text('Web (HTML/CSS/JS)'),
                        ),
                        DropdownMenuItem(
                          value: 'Python FastAPI',
                          child: Text('Python FastAPI'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _template = v);
                      },
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Превью структуры
                const Text(
                  'Структура файлов',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: files
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file_outlined,
                                    color: Colors.white70, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    f,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B8EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Создать проект',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  'Пока это сохранение структуры. Следующим шагом можем сделать “экспорт файлов” или генерацию кода.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
