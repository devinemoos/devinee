import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/main.dart';

void main() {
  testWidgets('DevineApp shows title', (WidgetTester tester) async {
    await tester.pumpWidget(DevineApp());

    // Проверяем, что на стартовом экране есть текст Devine
    expect(find.text('Devine'), findsOneWidget);
  });
}
