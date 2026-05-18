import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/auth_provider.dart';
import '../auth/login_screen.dart';

class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    final role = authProvider.user?.role;

    if (role == 'ENTREPRENEUR') {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard Emprendedor')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bienvenido Emprendedor a tus Servicios'),
              ElevatedButton(
                onPressed: () => authProvider.logout(),
                child: const Text('Cerrar Sesión'),
              )
            ],
          ),
        ),
      );
    }

    // Default: CLIENT
    return Scaffold(
      appBar: AppBar(title: const Text('Home Clientes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido Cliente - Buscar Servicios cercanos'),
            ElevatedButton(
              onPressed: () => authProvider.logout(),
              child: const Text('Cerrar Sesión'),
            )
          ],
        ),
      ),
    );
  }
}