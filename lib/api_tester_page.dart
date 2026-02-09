import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiTesterPage extends StatefulWidget {
  const ApiTesterPage({super.key});

  @override
  State<ApiTesterPage> createState() => _ApiTesterPageState();
}

class _ApiTesterPageState extends State<ApiTesterPage> {
  final _urlCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _method = 'GET';
  bool _loading = false;

  int? _statusCode;
  String _responseText = '';
  Map<String, String> _responseHeaders = {};

  List<_HistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // пример
    _urlCtrl.text = 'https://api.adviceslip.com/advice';
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _bodyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('api_history');
    if (raw == null || raw.isEmpty) return;

    try {
      final list = (jsonDecode(raw) as List).cast<dynamic>();
      setState(() {
        _history = list
            .map((e) => _HistoryItem.fromMap((e as Map).cast<String, dynamic>()))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_history.map((e) => e.toMap()).toList());
    await prefs.setString('api_history', raw);
  }

  Future<void> _addHistory(_HistoryItem item) async {
    _history.insert(0, item);
    if (_history.length > 15) {
      _history = _history.take(15).toList();
    }
    setState(() {});
    await _saveHistory();
  }

  bool _looksLikeUrl(String s) {
    final v = s.trim();
    return v.startsWith('http://') || v.startsWith('https://');
  }

  String _prettyJsonIfPossible(String raw) {
    try {
      final decoded = jsonDecode(raw);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _send() async {
    final url = _urlCtrl.text.trim();
    if (!_looksLikeUrl(url)) {
      _showMsg('Введите URL начиная с https://');
      return;
    }

    // body нужен только для не-GET
    String body = _bodyCtrl.text.trim();
    if (_method == 'GET') body = '';

    // если body введён — проверим JSON
    if (_method != 'GET' && body.isNotEmpty) {
      try {
        jsonDecode(body);
      } catch (_) {
        _showMsg('Body должен быть валидным JSON');
        return;
      }
    }

    setState(() {
      _loading = true;
      _statusCode = null;
      _responseText = '';
      _responseHeaders = {};
    });

    try {
      final uri = Uri.parse(url);
      final headers = <String, String>{
        'Accept': 'application/json',
      };

      http.Response res;

      if (_method == 'GET') {
        res = await http.get(uri, headers: headers);
      } else if (_method == 'POST') {
        res = await http.post(uri, headers: {
          ...headers,
          'Content-Type': 'application/json; charset=utf-8',
        }, body: body.isEmpty ? null : body);
      } else if (_method == 'PUT') {
        res = await http.put(uri, headers: {
          ...headers,
          'Content-Type': 'application/json; charset=utf-8',
        }, body: body.isEmpty ? null : body);
      } else if (_method == 'DELETE') {
        res = await http.delete(uri, headers: headers);
      } else {
        res = await http.get(uri, headers: headers);
      }

      final pretty = _prettyJsonIfPossible(res.body);

      setState(() {
        _statusCode = res.statusCode;
        _responseHeaders = Map<String, String>.from(res.headers);
        _responseText = pretty;
        _loading = false;
      });

      await _addHistory(
        _HistoryItem(
          method: _method,
          url: url,
          status: res.statusCode,
          at: DateTime.now(),
        ),
      );

      _scrollDown();
    } catch (e) {
      setState(() {
        _loading = false;
        _responseText = 'Ошибка запроса: $e';
      });
      _scrollDown();
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Color _statusColor(int code) {
    if (code >= 200 && code < 300) return Colors.greenAccent;
    if (code >= 300 && code < 400) return Colors.lightBlueAccent;
    if (code >= 400 && code < 500) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final showBody = _method != 'GET' && _method != 'DELETE';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('API тестер', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: _scrollCtrl,
          children: [
            // Method + URL
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.grey[900],
                      value: _method,
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'GET', child: Text('GET')),
                        DropdownMenuItem(value: 'POST', child: Text('POST')),
                        DropdownMenuItem(value: 'PUT', child: Text('PUT')),
                        DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _method = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _urlCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'https://...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (showBody) ...[
              const Text('Body (JSON)', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(
                controller: _bodyCtrl,
                style: const TextStyle(color: Colors.white),
                minLines: 4,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: '{ "key": "value" }',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B8EFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Отправить',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Response
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ответ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (_statusCode != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            '$_statusCode',
                            style: TextStyle(
                              color: _statusColor(_statusCode!),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_responseHeaders.isNotEmpty) ...[
                    const Text('Headers', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    ..._responseHeaders.entries.take(8).map(
                          (e) => Text(
                            '${e.key}: ${e.value}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                    const SizedBox(height: 12),
                  ],

                  const Text('Body', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  SelectableText(
                    _responseText.isEmpty ? '—' : _responseText,
                    style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // History
            Row(
              children: [
                const Text(
                  'История',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    setState(() => _history = []);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('api_history');
                  },
                  child: const Text('Очистить', style: TextStyle(color: Colors.white70)),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              const Text('Пока пусто', style: TextStyle(color: Colors.white54))
            else
              Column(
                children: _history.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          _method = h.method;
                          _urlCtrl.text = h.url;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                h.method,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                h.url,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${h.status}',
                              style: TextStyle(
                                color: _statusColor(h.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String method;
  final String url;
  final int status;
  final DateTime at;

  _HistoryItem({
    required this.method,
    required this.url,
    required this.status,
    required this.at,
  });

  Map<String, dynamic> toMap() => {
        'method': method,
        'url': url,
        'status': status,
        'at': at.toIso8601String(),
      };

  static _HistoryItem fromMap(Map<String, dynamic> m) => _HistoryItem(
        method: m['method'] ?? 'GET',
        url: m['url'] ?? '',
        status: m['status'] ?? 0,
        at: DateTime.tryParse(m['at'] ?? '') ?? DateTime.now(),
      );
}
