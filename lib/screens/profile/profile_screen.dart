import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../auth/welcome_screen.dart';
import '../services/my_services_screen.dart';
import 'edit_profile_screen.dart';
import 'reviews_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28)),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Text(user.name,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    user.isEmprendedor ? 'Emprendedor' : 'Cliente',
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (user.description != null &&
                    user.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(user.description!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
                if (user.location != null && user.location!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(user.location!,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
                if (user.isEmprendedor && user.reviewCount > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${user.averageRating.toStringAsFixed(1)} · ${user.reviewCount} reseñas',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                            context, EditProfileScreen.routeName),
                        child: const Text('Editar perfil'),
                      ),
                    ),
                    if (user.isEmprendedor) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pushNamed(
                              context, MyServicesScreen.routeName),
                          child: const Text('Mis servicios'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ProfileOption(
            icon: Icons.star_outline,
            title: 'Reseñas y calificaciones',
            onTap: () => Navigator.pushNamed(
              context,
              ReviewsScreen.routeName,
              arguments: {
                'targetUserId': user.uid,
                'canReview': false,
              },
            ),
          ),
          _ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Preferencias',
              onTap: () {}),
          _ProfileOption(icon: Icons.help_outline, title: 'Ayuda', onTap: () {}),
          _ProfileOption(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            destructive: true,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content:
                      const Text('¿Seguro que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(
                    context, WelcomeScreen.routeName);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: destructive ? Colors.red : null),
        title: Text(title,
            style: TextStyle(color: destructive ? Colors.red : null)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
