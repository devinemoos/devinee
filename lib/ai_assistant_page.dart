import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg.bot(
      'Привет! Я ИИ Ассистент Devine 🤖\n'
      'Могу помочь с Flutter, ошибками, структурой проекта, идеями.\n\n'
      'Напиши вопрос или вставь текст ошибки.',
    ),
  ];

  bool _sending = false;
  bool _isPlus = false;
  int _freeLeft = 10; // лимит сообщений в Free за сессию

  @override
  void initState() {
    super.initState();
    _loadPlus();
  }

  Future<void> _loadPlus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPlus = prefs.getBool('isPlus') ?? false;
      if (_isPlus) _freeLeft = 999999;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    if (!_isPlus && _freeLeft <= 0) {
      _showLimitDialog();
      return;
    }

    setState(() {
      _sending = true;
      _messages.add(_ChatMsg.user(text));
      _controller.clear();
      if (!_isPlus) _freeLeft--;
    });

    _scrollDown();

    // "думает"
    await Future.delayed(const Duration(milliseconds: 300));
    final reply = _generateReply(text);

    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMsg.bot(reply));
      _sending = false;
    });

    _scrollDown();
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Лимит Free', style: TextStyle(color: Colors.white)),
        content: const Text(
          'В бесплатной версии ИИ Ассистент ограничен.\n\n'
          'Перейди на PLUS, чтобы снять лимиты.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ок', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  String _generateReply(String input) {
    final s = input.toLowerCase();

    // Частые ошибки Flutter/Dart
    if (s.contains('navigator') && s.contains('does not include a navigator')) {
      return 'Похоже на ошибку навигации.\n\n'
          '✅ Обычно это значит, что ты вызываешь Navigator из контекста, который не внутри MaterialApp/Scaffold.\n'
          'Решение:\n'
          '1) Убедись, что приложение запускается через MaterialApp.\n'
          '2) Вызывай Navigator из контекста экрана (Scaffold), а не из main() до MaterialApp.\n'
          '3) Если это диалог/виджет — используй context, который ближе к Scaffold.\n\n'
          'Скинь кусок кода где нажимаешь кнопку — скажу точнее.';
    }

    if (s.contains('target of uri doesn\'t exist') || s.contains('uri doesn')) {
      return 'Это значит, что импорт не находится.\n\n'
          '✅ Проверь:\n'
          '• файл реально существует в папке lib\n'
          '• имя файла/путь совпадает (регистр букв тоже важен)\n'
          '• после изменения pubspec.yaml делал flutter pub get\n\n'
          'Напиши строку import — я скажу что не так.';
    }

    if (s.contains('shared_preferences') || s.contains('sharedpreferences')) {
      return 'Если ругается на shared_preferences:\n\n'
          '✅ Проверь pubspec.yaml:\n'
          'dependencies:\n'
          '  shared_preferences: ^2.2.3\n\n'
          'Потом:\n'
          'flutter pub get\n'
          'и перезапусти VS Code.\n\n'
          'Если хочешь — скинь текст ошибки, я скажу точнее.';
    }

    // Flutter UI подсказки
    if (s.contains('flutter') || s.contains('dart')) {
      return 'По Flutter/Dart могу помочь.\n\n'
          'Скажи, что именно нужно:\n'
          '• UI (экраны/кнопки/карточки)\n'
          '• навигация\n'
          '• сохранение данных (SharedPreferences/SQLite)\n'
          '• работа с API\n\n'
          'Если есть ошибка — скинь текст из терминала.';
    }

    // API/HTTP
    if (s.contains('api') || s.contains('http') || s.contains('json')) {
      return 'По API:\n\n'
          '✅ Правильный план:\n'
          '1) сформировать запрос (GET/POST)\n'
          '2) обработать статус-код\n'
          '3) распарсить JSON\n'
          '4) показать результат/ошибку в UI\n\n'
          'Скинь пример URL и что хочешь получить — я напишу код.';
    }

    // Пароль/email/валидация
    if (s.contains('пароль') || s.contains('email') || s.contains('почт')) {
      return 'По регистрации/валидации:\n\n'
          '✅ Email: regex + trim\n'
          '✅ Пароль: минимум 8 символов + буква + цифра\n'
          '✅ Сохранение: SharedPreferences (isLoggedIn, email)\n\n'
          'Если хочешь — добавим “повтор пароля” и “забыли пароль”.';
    }

    // Проекты/подписка
    if (s.contains('проект') || s.contains('plus') || s.contains('подписк')) {
      return 'По проектам/PLUS:\n\n'
          '✅ Free: лимит проектов (например 3)\n'
          '✅ PLUS: безлимит\n'
          '✅ UI: показывать статус + скрывать кнопку PLUS\n\n'
          'Хочешь: добавить “избранное”, поиск и редактирование проектов?';
    }

    // дефолт
    return 'Понял 👍\n\n'
        'Можешь уточнить:\n'
        '1) что именно нужно сделать\n'
        '2) где (какой файл/экран)\n'
        '3) если ошибка — скинь текст ошибки\n\n'
        'Я подскажу и дам готовый код.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ИИ Ассистент', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                _isPlus ? 'PLUS ✅' : 'Free: $_freeLeft',
                style: TextStyle(
                  color: _isPlus ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment:
                      m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: m.isUser ? const Color(0xFF9B8EFF) : Colors.grey[850],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: m.isUser ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Напиши сообщение...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 46,
                  width: 46,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B8EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: _sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
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

class _ChatMsg {
  final bool isUser;
  final String text;

  _ChatMsg._(this.isUser, this.text);

  factory _ChatMsg.user(String t) => _ChatMsg._(true, t);
  factory _ChatMsg.bot(String t) => _ChatMsg._(false, t);
}
