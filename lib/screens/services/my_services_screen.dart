import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/service_card.dart';
import 'create_service_screen.dart';

class MyServicesScreen extends StatelessWidget {
  static const routeName = '/my-services';

  const MyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis servicios'),
      ),
      body: StreamBuilder<List<ServiceModel>>(
        stream: FirestoreService().myServicesStream(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snap.data ?? [];

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_outlined,
                      size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes servicios publicados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, CreateServiceScreen.routeName),
                    icon: const Icon(Icons.add),
                    label: const Text('Publicar servicio'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: services.length,
            itemBuilder: (_, index) {
              final service = services[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    ServiceCard(service: service),
                    // Menú de acciones (editar / eliminar / toggle estado)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _ServiceActionsMenu(service: service),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, CreateServiceScreen.routeName),
        label: const Text('Nuevo servicio'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _ServiceActionsMenu extends StatelessWidget {
  final ServiceModel service;

  const _ServiceActionsMenu({required this.service});

  @override
  Widget build(BuildContext context) {
    final svcProv = context.read<ServicesProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          switch (value) {
            case 'edit':
              Navigator.pushNamed(
                context,
                CreateServiceScreen.routeName,
                arguments: {
                  'editServiceId': service.id,
                  'initialData': {
                    'title': service.title,
                    'category': service.category,
                    'price': service.price,
                    'location': service.location,
                    'description': service.description,
                    'active': service.active,
                  },
                },
              );
              break;
            case 'toggle':
              await svcProv.toggleServiceStatus(service);
              break;
            case 'delete':
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar servicio'),
                  content: Text(
                      '¿Seguro que quieres eliminar "${service.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await svcProv.deleteService(service.id);
              }
              break;
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 8),
              const Text('Editar'),
            ]),
          ),
          PopupMenuItem(
            value: 'toggle',
            child: Row(children: [
              Icon(
                service.active
                    ? Icons.toggle_off_outlined
                    : Icons.toggle_on_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(service.active ? 'Desactivar' : 'Activar'),
            ]),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Eliminar',
                  style: TextStyle(color: Colors.red)),
            ]),
          ),
        ],
      ),
    );
  }
}
