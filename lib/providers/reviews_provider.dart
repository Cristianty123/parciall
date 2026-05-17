import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ReviewsProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Stream<List<ReviewModel>> reviewsStream(String targetUserId) =>
      _fs.reviewsStream(targetUserId);

  Future<bool> submitReview({
    required UserModel author,
    required String targetUserId,
    required String serviceId,
    required double rating,
    required String comment,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar si ya calificó este servicio
      final alreadyReviewed = await _fs.hasReviewed(
        authorId: author.uid,
        serviceId: serviceId,
      );

      if (alreadyReviewed) {
        _error = 'Ya calificaste este servicio.';
        _loading = false;
        notifyListeners();
        return false;
      }

      final review = ReviewModel(
        id: '',
        authorId: author.uid,
        authorName: author.name,
        authorPhotoUrl: author.photoUrl,
        targetUserId: targetUserId,
        serviceId: serviceId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _fs.createReview(review);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al enviar la reseña: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
