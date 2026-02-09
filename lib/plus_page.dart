import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlusPage extends StatelessWidget {
  const PlusPage({super.key});

  Future<void> _activatePlusDemo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPlus', true);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PLUS активирован (демо) ✅')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Devine PLUS', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Перейти на ПЛЮС',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Подписка открывает расширенные функции и снимает ограничения.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _feature('✅ Безлимитные проекты'),
            _feature('✅ Расширенный API тестер'),
            _feature('✅ ИИ ассистент PRO'),
            _feature('✅ Приоритетная скорость'),
            const SizedBox(height: 24),

            // DEMO кнопка
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _activatePlusDemo(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B8EFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Активировать PLUS (демо)',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Позже подключим реальную оплату через In-App Purchases.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
