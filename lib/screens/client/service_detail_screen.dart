// lib/screens/client/service_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/storage.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../shared/public_profile_screen.dart';
import '../shared/chat_screen.dart';
import '../shared/review_form_screen.dart';
import '../shared/reviews_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  ServiceDetail? _service;
  bool _loading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _role = await AppStorage.getRole();
    try {
      final res = await ApiClient.get('/services/${widget.serviceId}');
      if (res.statusCode == 200) {
        setState(
            () => _service = ServiceDetail.fromJson(json.decode(res.body)));
      }
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Servicio no encontrado')),
      );
    }
    final s = _service!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: s.imageUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: s.imageUrls.length,
                      itemBuilder: (_, i) => Image.network(
                        s.imageUrls[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 60)),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.storefront, size: 80)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & status
                  Row(
                    children: [
                      if (s.categoryName != null)
                        Chip(
                          label: Text(s.categoryName!),
                          visualDensity: VisualDensity.compact,
                        ),
                      const Spacer(),
                      StatusBadge(status: s.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      StarRating(rating: s.averageRating),
                      const SizedBox(width: 6),
                      Text(
                          '${s.averageRating.toStringAsFixed(1)} · ${s.totalReviews} reseñas',
                          style: TextStyle(color: Colors.grey.shade600)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(
                                entrepreneurId: s.entrepreneurId),
                          ),
                        ),
                        child: const Text('Ver reseñas'),
                      ),
                    ],
                  ),
                  if (s.price != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '\$${s.price!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  if (s.description != null) ...[
                    const Text('Descripción',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(s.description!,
                        style: TextStyle(color: Colors.grey.shade700)),
                    const Divider(height: 24),
                  ],
                  if (s.address != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Expanded(child: Text(s.address!)),
                      ],
                    ),
                    const Divider(height: 24),
                  ],
                  // Entrepreneur info
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(
                            entrepreneurId: s.entrepreneurId),
                      ),
                    ),
                    child: Row(
                      children: [
                        UserAvatar(photoUrl: s.entrepreneurPhotoUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  s.entrepreneurFullName ??
                                      'Emprendedor',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const Text('Ver perfil completo',
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Actions for CLIENT
                  if (_role == AppConstants.roleClient) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Contactar'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            partnerId: s.entrepreneurId,
                            partnerName:
                                s.entrepreneurFullName ?? 'Emprendedor',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Escribir reseña'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewFormScreen(
                            entrepreneurId: s.entrepreneurId,
                            servicePostId: s.id,
                            serviceTitle: s.title,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
