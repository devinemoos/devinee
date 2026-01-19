import 'package:flutter/material.dart';

void main() {
  runApp(DevineApp());
}

class DevineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Devine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Инновационный инструмент для разработчиков',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Упрощает создание, и тестирование и внедрение программных решений',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {}, // функционал пока не нужен
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9B8EFF), // фиолетовый
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Начать работу',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Автоматизируйте рутинные задачи',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Ускорьте разработку',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Повышайте продуктивность',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Упрощает создание и внедрение программ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
