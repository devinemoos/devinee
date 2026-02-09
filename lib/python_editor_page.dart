import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'project_storage.dart';

class PythonEditorPage extends StatefulWidget {
  final ProjectEntry project;

  const PythonEditorPage({
    super.key,
    required this.project,
  });

  @override
  State<PythonEditorPage> createState() => _PythonEditorPageState();
}

class _PythonEditorPageState extends State<PythonEditorPage> {
  final _controller = TextEditingController();
  bool _saving = false;

  String get _storageKey => 'python_code_${widget.project.id}';

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    _controller.text = code ??
        '''# ${widget.project.title}
# Python project

def main():
    print("Hello, Devine!")

if __name__ == "__main__":
    main()
''';
  }

  Future<void> _saveCode() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _controller.text);
    setState(() => _saving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Код сохранён ✅')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.project.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _saveCode,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
