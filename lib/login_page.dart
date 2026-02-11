import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'glav.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _hidePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    return RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$').hasMatch(v.trim());
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('${password.trim()}$salt');
    return sha256.convert(bytes).toString();
  }

  Future<void> _login() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString('email');
    final savedSalt = prefs.getString('passwordSalt');
    final savedHash = prefs.getString('passwordHash');

    if (savedEmail == null || savedSalt == null || savedHash == null) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аккаунт не найден. Сначала зарегистрируйтесь.')),
      );
      return;
    }

    final inputEmail = _emailCtrl.text.trim();
    final inputHash = _hashPassword(_passCtrl.text, savedSalt);

    final emailOk = inputEmail.toLowerCase() == savedEmail.toLowerCase();
    final passOk = inputHash == savedHash;

    if (!emailOk || !passOk) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный email или пароль')),
      );
      return;
    }

    // ✅ логин успешен
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GlavPage()),
      (route) => false,
    );
  }

  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Вход', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Email'),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Введите email';
                  if (!_isValidEmail(s)) return 'Неверный формат email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _hidePass,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Пароль').copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePass = !_hidePass),
                    icon: Icon(
                      _hidePass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                  ),
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Введите пароль';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B8EFF),
                  minimumSize: const Size(double.infinity, 52),
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
                        'Войти',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Нет аккаунта? Регистрация',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
