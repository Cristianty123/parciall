// lib/widgets/widgets.dart
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

// ── Avatar ────────────────────────────────────────────────────────────

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;

  const UserAvatar({super.key, this.photoUrl, this.radius = 28});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: Colors.grey.shade200,
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primary.withOpacity(0.15),
      child: Icon(Icons.person, size: radius, color: AppTheme.primary),
    );
  }
}

// ── Star rating display ───────────────────────────────────────────────

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, size: size, color: AppTheme.accent);
        } else if (i < rating) {
          return Icon(Icons.star_half, size: size, color: AppTheme.accent);
        }
        return Icon(Icons.star_border, size: size, color: Colors.grey.shade400);
      }),
    );
  }
}

// ── Interactive star selector ─────────────────────────────────────────

class StarSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final double size;

  const StarSelector({
    super.key,
    required this.selected,
    required this.onSelect,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => onSelect(i + 1),
          child: Icon(
            i < selected ? Icons.star : Icons.star_border,
            size: size,
            color: AppTheme.accent,
          ),
        );
      }),
    );
  }
}

// ── Role badge ────────────────────────────────────────────────────────

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isEntrepreneur = role == AppConstants.roleEntrepreneur;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isEntrepreneur
            ? AppTheme.accent.withOpacity(0.15)
            : AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEntrepreneur ? AppTheme.accent : AppTheme.primary,
          width: 1,
        ),
      ),
      child: Text(
        isEntrepreneur ? 'Emprendedor' : 'Cliente',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isEntrepreneur ? AppTheme.accent : AppTheme.primary,
        ),
      ),
    );
  }
}

// ── Service status badge ──────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
        ),
      ),
    );
  }
}

// ── Loading overlay ───────────────────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────

class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service card widget ───────────────────────────────────────────────

class ServiceCardWidget extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? category;
  final double? price;
  final double rating;
  final int reviews;
  final String? entrepreneurName;
  final VoidCallback onTap;

  const ServiceCardWidget({
    super.key,
    required this.title,
    this.imageUrl,
    this.category,
    this.price,
    required this.rating,
    required this.reviews,
    this.entrepreneurName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null)
                    Text(
                      category!,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(rating: rating, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)} ($reviews)',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (price != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '\$${price!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Icon(Icons.image_outlined,
            size: 48, color: Colors.grey.shade400),
      );
}
