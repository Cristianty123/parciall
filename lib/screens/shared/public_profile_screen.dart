// lib/screens/shared/public_profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'chat_screen.dart';
import 'reviews_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final int entrepreneurId;
  const PublicProfileScreen({super.key, required this.entrepreneurId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  EntrepreneurProfile? _profile;
  ReviewSummary? _summary;
  List<ReviewItem> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.get('/users/${widget.entrepreneurId}'),
        ApiClient.get(
            '/reviews/entrepreneur/${widget.entrepreneurId}/summary'),
        ApiClient.get(
            '/reviews/entrepreneur/${widget.entrepreneurId}',
            {'page': '0', 'size': '5'}),
      ]);
      if (results[0].statusCode == 200) {
        _profile = EntrepreneurProfile.fromJson(
            json.decode(results[0].body));
      }
      if (results[1].statusCode == 200) {
        _summary =
            ReviewSummary.fromJson(json.decode(results[1].body));
      }
      if (results[2].statusCode == 200) {
        final paged = PagedResponse.fromJson(
            json.decode(results[2].body), ReviewItem.fromJson);
        _reviews = paged.content;
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
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Perfil no encontrado')),
      );
    }
    final p = _profile!;
    return Scaffold(
      appBar: AppBar(title: Text(p.fullName ?? 'Emprendedor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Center(
            child: Column(
              children: [
                UserAvatar(photoUrl: p.photoUrl, radius: 50),
                const SizedBox(height: 10),
                Text(p.fullName ?? 'Sin nombre',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                if (p.description != null) ...[
                  const SizedBox(height: 6),
                  Text(p.description!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
                if (p.address != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppTheme.primary),
                      Text(p.address!,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Rating summary
          if (_summary != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _summary!.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarRating(
                                rating: _summary!.averageRating,
                                size: 22),
                            Text(
                                '${_summary!.totalReviews} reseñas',
                                style: TextStyle(
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Distribution bars
                    ...['5', '4', '3', '2', '1'].map((k) {
                      final count =
                          _summary!.distribution[k] ?? 0;
                      final total = _summary!.totalReviews;
                      final pct = total > 0 ? count / total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$k★',
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor:
                                    Colors.grey.shade200,
                                color: AppTheme.accent,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('$count',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Contactar button
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Contactar'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  partnerId: p.id,
                  partnerName: p.fullName ?? 'Emprendedor',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Last reviews
          if (_reviews.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Últimas reseñas',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewsScreen(
                          entrepreneurId: widget.entrepreneurId),
                    ),
                  ),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            ..._reviews.map((r) => _ReviewTile(review: r)),
          ],
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewItem review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(photoUrl: review.clientPhotoUrl, radius: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(review.clientFullName ?? 'Usuario',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                StarRating(rating: review.rating, size: 14),
              ],
            ),
            if (review.serviceTitle != null) ...[
              const SizedBox(height: 4),
              Text('Servicio: ${review.serviceTitle}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
            ],
            if (review.comment != null) ...[
              const SizedBox(height: 6),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }
}
