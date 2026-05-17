// lib/screens/entrepreneur/dashboard_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../shared/profile_screen.dart';
import '../shared/chat_list_screen.dart';
import 'service_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ServiceSummary> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.get('/services/my-services');
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        setState(
            () => _services = list.map((e) => ServiceSummary.fromJson(e)).toList());
      }
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(ServiceSummary s) async {
    final newStatus = s.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      final res = await ApiClient.patch(
          '/services/${s.id}/status', {'status': newStatus});
      if (res.statusCode == 200) _load();
    } catch (_) {}
  }

  Future<void> _delete(ServiceSummary s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text('¿Eliminar "${s.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final res = await ApiClient.delete('/services/${s.id}');
      if (res.statusCode == 204) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatListScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ServiceFormScreen()));
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo servicio'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _services.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.storefront_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No tienes servicios publicados',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _services.length,
                      itemBuilder: (_, i) {
                        final s = _services[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: s.imageUrls.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      s.imageUrls.first,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image, size: 40),
                                    ),
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.storefront,
                                        color: AppTheme.primary),
                                  ),
                            title: Text(s.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (s.categoryName != null)
                                  Text(s.categoryName!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primary)),
                                if (s.price != null)
                                  Text('\$${s.price!.toStringAsFixed(0)}'),
                                const SizedBox(height: 4),
                                StatusBadge(status: s.status),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ServiceFormScreen(service: s),
                                    ),
                                  ).then((_) => _load());
                                } else if (v == 'status') {
                                  _toggleStatus(s);
                                } else if (v == 'delete') {
                                  _delete(s);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 8),
                                      Text('Editar')
                                    ])),
                                PopupMenuItem(
                                    value: 'status',
                                    child: Row(children: [
                                      Icon(s.status == 'ACTIVE'
                                          ? Icons.pause_circle_outline
                                          : Icons.play_circle_outline),
                                      const SizedBox(width: 8),
                                      Text(s.status == 'ACTIVE'
                                          ? 'Desactivar'
                                          : 'Activar')
                                    ])),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar',
                                          style:
                                              TextStyle(color: Colors.red))
                                    ])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
