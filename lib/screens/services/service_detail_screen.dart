import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/section_title.dart';
import '../chat/chat_detail_screen.dart';
import '../profile/reviews_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  static const routeName = '/service-detail';

  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  Future<void> _openChat(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final chatProv = context.read<ChatProvider>();

    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para chatear.')),
      );
      return;
    }

    if (auth.currentUser!.uid == service.providerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes contactarte a ti mismo.')),
      );
      return;
    }

    final chatId = await chatProv.openOrCreateChat(
      currentUserId: auth.currentUser!.uid,
      currentUserName: auth.currentUser!.name,
      currentUserPhoto: auth.currentUser!.photoUrl,
      otherUserId: service.providerId,
      otherUserName: service.providerName,
      otherUserPhoto: service.providerPhotoUrl,
      serviceId: service.id,
      serviceTitle: service.title,
    );

    if (chatId == null || !context.mounted) return;

    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: {
        'chatId': chatId,
        'otherUserId': service.providerId,
        'otherUserName': service.providerName,
        'otherUserPhoto': service.providerPhotoUrl,
      },
    );
  }

  void _openReviews(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isClient = auth.currentUser != null && !auth.currentUser!.isEmprendedor;
    final isNotOwner = auth.currentUser?.uid != service.providerId;

    Navigator.pushNamed(
      context,
      ReviewsScreen.routeName,
      arguments: {
        'targetUserId': service.providerId,
        'serviceId': service.id,
        'canReview': isClient && isNotOwner,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.currentUser?.uid == service.providerId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: service.imageUrls.isNotEmpty
                  ? Image.network(service.imageUrls.first, fit: BoxFit.cover)
                  : Image.network(
                      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
                      fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: service.active
                              ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          service.active ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: service.active
                                ? const Color(0xFF22C55E)
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          service.category,
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(service.title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(service.providerName,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 10),

                  // Rating clickable
                  GestureDetector(
                    onTap: () => _openReviews(context),
                    child: Row(
                      children: [
                        RatingStars(rating: service.rating),
                        const SizedBox(width: 8),
                        Text(
                          '${service.rating.toStringAsFixed(1)} (${service.reviewCount} reseñas)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 6),
                      Expanded(child: Text(service.location)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(service.description),
                  ),

                  if (service.imageUrls.length > 1) ...[
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'Galería'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(service.imageUrls[i],
                              width: 140, fit: BoxFit.cover),
                        ),
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemCount: service.imageUrls.length,
                      ),
                    ),
                  ],

                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Precio estimado'),
                              const SizedBox(height: 4),
                              Text(service.price,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: const Color(0xFF4F46E5))),
                            ],
                          ),
                        ),
                        if (!isOwner)
                          FilledButton.icon(
                            onPressed:
                                chatProv.loading ? null : () => _openChat(context),
                            icon: chatProv.loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.chat_bubble_outline),
                            label: const Text('Contactar'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
