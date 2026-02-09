import 'dart:convert';
import 'package:http/http.dart' as http;

class AdviceService {
  static Future<String?> fetchAdvice() async {
    final url = Uri.parse('https://api.adviceslip.com/advice');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['slip']['advice'] as String;
    } else {
      return null;
    }
  }
}
