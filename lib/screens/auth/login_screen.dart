// lib/screens/auth/login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/storage.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'register_screen.dart';
import '../client/home_screen.dart';
import '../entrepreneur/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.post(
        '/authenticate/login',
        {'username': _usernameCtrl.text.trim(), 'password': _passwordCtrl.text},
        auth: false,
      );
      final data = LoginResponse.fromJson(json.decode(res.body));
      if (data.success && data.token != null) {
        await AppStorage.saveSession(
          token: data.token!,
          role: data.role!,
          username: data.username!,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => data.role == AppConstants.roleEntrepreneur
              ? const DashboardScreen()
              : const HomeScreen(),
        ));
      } else {
        setState(
            () => _error = data.message ?? 'Usuario o contraseña incorrectos');
      }
    } catch (_) {
      setState(() => _error = 'Error de conexión. Verifica tu red.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C6BC0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.storefront,
                          size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LabApp',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Conecta con emprendedores locales',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('Iniciar sesión',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (_error != null) ErrorBanner(message: _error!),
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              LoadingOverlay(
                loading: _loading,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: const Text('Ingresar',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
