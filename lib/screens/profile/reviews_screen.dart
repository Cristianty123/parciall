import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reviews_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/rating_stars.dart';

class ReviewsScreen extends StatelessWidget {
  static const routeName = '/reviews';

  final String? targetUserId;
  final String? serviceId;
  final bool canReview;

  const ReviewsScreen({
    super.key,
    this.targetUserId,
    this.serviceId,
    this.canReview = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final effectiveTargetId =
        targetUserId ?? auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas'),
        actions: [
          if (canReview && serviceId != null)
            TextButton.icon(
              onPressed: () => _showReviewDialog(context, effectiveTargetId),
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Calificar'),
            ),
        ],
      ),
      body: StreamBuilder<List<ReviewModel>>(
        stream: FirestoreService().reviewsStream(effectiveTargetId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snap.data ?? [];

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_outline, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aún no hay reseñas.',
                      style: TextStyle(color: Colors.grey)),
                  if (canReview && serviceId != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          _showReviewDialog(context, effectiveTargetId),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Dejar reseña'),
                    ),
                  ],
                ],
              ),
            );
          }

          final avgRating = reviews.fold<double>(
                  0, (sum, r) => sum + r.rating) /
              reviews.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Resumen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    const Text('Promedio general',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RatingStars(rating: avgRating),
                    const SizedBox(height: 6),
                    Text(
                      '${reviews.length} reseña${reviews.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...reviews.map((review) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: review.authorPhotoUrl != null
                                    ? NetworkImage(review.authorPhotoUrl!)
                                    : null,
                                child: review.authorPhotoUrl == null
                                    ? Text(review.authorName.isNotEmpty
                                        ? review.authorName[0].toUpperCase()
                                        : '?')
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  review.authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                _formatDate(review.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RatingStars(rating: review.rating),
                          const SizedBox(height: 8),
                          Text(review.comment),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _showReviewDialog(BuildContext context, String targetId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewBottomSheet(
        targetUserId: targetId,
        serviceId: serviceId!,
      ),
    );
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  final String targetUserId;
  final String serviceId;

  const _ReviewBottomSheet(
      {required this.targetUserId, required this.serviceId});

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  double _rating = 5;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ReviewsProvider>().loading;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Dejar reseña',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Estrellas interactivas
          const Text('Calificación'),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_outline,
                    color: const Color(0xFFF59E0B),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comentario *',
              hintText: 'Comparte tu experiencia...',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Enviar reseña'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un comentario.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final reviewsProv = context.read<ReviewsProvider>();

    if (auth.currentUser == null) return;

    final ok = await reviewsProv.submitReview(
      author: auth.currentUser!,
      targetUserId: widget.targetUserId,
      serviceId: widget.serviceId,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reseña enviada exitosamente!'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reviewsProv.error ?? 'Error al enviar reseña.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}
