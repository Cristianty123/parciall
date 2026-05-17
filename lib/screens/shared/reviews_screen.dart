// lib/screens/shared/reviews_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class ReviewsScreen extends StatefulWidget {
  final int entrepreneurId;
  const ReviewsScreen({super.key, required this.entrepreneurId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  ReviewSummary? _summary;
  List<ReviewItem> _reviews = [];
  bool _loading = true;
  int _page = 0;
  bool _hasMore = true;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadReviews(reset: true);
    _scrollCtrl.addListener(_onScroll);
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 150 &&
        _hasMore &&
        !_loading) {
      _loadReviews();
    }
  }

  Future<void> _loadSummary() async {
    try {
      final res = await ApiClient.get(
          '/reviews/entrepreneur/${widget.entrepreneurId}/summary');
      if (res.statusCode == 200) {
        setState(
            () => _summary = ReviewSummary.fromJson(json.decode(res.body)));
      }
    } catch (_) {}
  }

  Future<void> _loadReviews({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _hasMore = true;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiClient.get(
          '/reviews/entrepreneur/${widget.entrepreneurId}',
          {'page': _page, 'size': '10'});
      final paged = PagedResponse.fromJson(
          json.decode(res.body), ReviewItem.fromJson);
      setState(() {
        if (reset) {
          _reviews = paged.content;
        } else {
          _reviews.addAll(paged.content);
        }
        _hasMore = _page < paged.totalPages - 1;
        _page++;
      });
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas')),
      body: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(12),
        itemCount: _reviews.length + 2, // summary card + loader
        itemBuilder: (_, i) {
          if (i == 0) return _buildSummaryCard();
          if (i == _reviews.length + 1) {
            return _hasMore
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator()))
                : const SizedBox.shrink();
          }
          return _ReviewCard(review: _reviews[i - 1]);
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_summary == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  _summary!.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 44, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarRating(rating: _summary!.averageRating, size: 24),
                    Text('${_summary!.totalReviews} reseñas',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...['5', '4', '3', '2', '1'].map((k) {
              final count = _summary!.distribution[k] ?? 0;
              final total = _summary!.totalReviews;
              final pct = total > 0 ? count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('$k★',
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.accent,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      child: Text('$count',
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewItem review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(photoUrl: review.clientPhotoUrl, radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.clientFullName ?? 'Usuario',
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      if (review.createdAt != null)
                        Text(
                          _formatDate(review.createdAt!),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                ),
                StarRating(rating: review.rating, size: 15),
              ],
            ),
            if (review.serviceTitle != null) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.serviceTitle!,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.primary),
                ),
              ),
            ],
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return timeago.format(dt, locale: 'es');
    } catch (_) {
      return isoString;
    }
  }
}
