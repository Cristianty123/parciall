// lib/screens/auth/register_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/storage.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../client/home_screen.dart';
import '../entrepreneur/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _role = AppConstants.roleClient;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.post(
        '/authenticate/register',
        {
          'username': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'role': _role,
        },
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
        setState(() => _error = data.message ?? 'Error al registrarse');
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
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elige tu rol',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      label: 'Cliente',
                      icon: Icons.person_search,
                      desc: 'Busca y contrata servicios',
                      selected: _role == AppConstants.roleClient,
                      onTap: () =>
                          setState(() => _role = AppConstants.roleClient),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleCard(
                      label: 'Emprendedor',
                      icon: Icons.storefront,
                      desc: 'Publica y gestiona servicios',
                      selected: _role == AppConstants.roleEntrepreneur,
                      onTap: () => setState(
                          () => _role = AppConstants.roleEntrepreneur),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 24),
              LoadingOverlay(
                loading: _loading,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: const Text('Registrarme',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF5C6BC0).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF5C6BC0)
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32,
                color: selected
                    ? const Color(0xFF5C6BC0)
                    : Colors.grey.shade500),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? const Color(0xFF5C6BC0)
                        : Colors.black87)),
            const SizedBox(height: 4),
            Text(desc,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
