import 'dart:convert';
import 'package:http/http.dart' as http;

class IpService {
  static const String _apiKey = 'e78b0f162963386ca8e107ad42e13bae';

  static Future<Map<String, dynamic>?> fetchIpInfo() async {
    final url =
        Uri.parse('http://api.ipstack.com/check?access_key=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
