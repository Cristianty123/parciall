import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../models/review_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────────────────────────────────────────
  // SERVICIOS
  // ────────────────────────────────────────────

  /// Stream de todos los servicios activos
  Stream<List<ServiceModel>> servicesStream({String? category}) {
    Query query = _db
        .collection('services')
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => ServiceModel.fromFirestore(d)).toList());
  }

  /// Stream de servicios de un emprendedor específico
  Stream<List<ServiceModel>> myServicesStream(String providerId) {
    return _db
        .collection('services')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ServiceModel.fromFirestore(d)).toList());
  }

  /// Buscar servicios por texto (título o categoría)
  Future<List<ServiceModel>> searchServices(String query) async {
    final lower = query.toLowerCase();

    final snap = await _db
        .collection('services')
        .where('active', isEqualTo: true)
        .get();

    return snap.docs
        .map((d) => ServiceModel.fromFirestore(d))
        .where((s) =>
            s.title.toLowerCase().contains(lower) ||
            s.category.toLowerCase().contains(lower) ||
            s.description.toLowerCase().contains(lower))
        .toList();
  }

  /// Crear un servicio
  Future<String> createService(ServiceModel service) async {
    final ref = await _db.collection('services').add(service.toMap());
    return ref.id;
  }

  /// Actualizar un servicio
  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await _db.collection('services').doc(serviceId).update(data);
  }

  /// Eliminar un servicio
  Future<void> deleteService(String serviceId) async {
    await _db.collection('services').doc(serviceId).delete();
  }

  /// Obtener un servicio por ID
  Future<ServiceModel?> getService(String serviceId) async {
    final doc = await _db.collection('services').doc(serviceId).get();
    if (!doc.exists) return null;
    return ServiceModel.fromFirestore(doc);
  }

  // ────────────────────────────────────────────
  // RESEÑAS
  // ────────────────────────────────────────────

  /// Stream de reseñas de un emprendedor
  Stream<List<ReviewModel>> reviewsStream(String targetUserId) {
    return _db
        .collection('reviews')
        .where('targetUserId', isEqualTo: targetUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReviewModel.fromFirestore(d)).toList());
  }

  /// Verificar si el cliente ya calificó a este emprendedor por este servicio
  Future<bool> hasReviewed({
    required String authorId,
    required String serviceId,
  }) async {
    final snap = await _db
        .collection('reviews')
        .where('authorId', isEqualTo: authorId)
        .where('serviceId', isEqualTo: serviceId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Crear reseña y actualizar rating del emprendedor
  Future<void> createReview(ReviewModel review) async {
    // Guardar reseña
    await _db.collection('reviews').add(review.toMap());

    // Recalcular promedio del emprendedor en Firestore usando transacción
    final userRef = _db.collection('users').doc(review.targetUserId);
    await _db.runTransaction((txn) async {
      final userDoc = await txn.get(userRef);
      final data = userDoc.data() as Map<String, dynamic>;
      final currentAvg = (data['averageRating'] ?? 0.0).toDouble();
      final currentCount = (data['reviewCount'] ?? 0) as int;

      final newCount = currentCount + 1;
      final newAvg =
          ((currentAvg * currentCount) + review.rating) / newCount;

      txn.update(userRef, {
        'averageRating': newAvg,
        'reviewCount': newCount,
      });
    });

    // Actualizar rating en el servicio también
    final serviceRef = _db.collection('services').doc(review.serviceId);
    await _db.runTransaction((txn) async {
      final serviceDoc = await txn.get(serviceRef);
      if (!serviceDoc.exists) return;
      final data = serviceDoc.data() as Map<String, dynamic>;
      final currentAvg = (data['rating'] ?? 0.0).toDouble();
      final currentCount = (data['reviewCount'] ?? 0) as int;
      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + review.rating) / newCount;
      txn.update(serviceRef, {
        'rating': newAvg,
        'reviewCount': newCount,
      });
    });
  }

  // ────────────────────────────────────────────
  // CHATS
  // ────────────────────────────────────────────

  /// Stream de chats del usuario actual
  Stream<List<ChatModel>> chatsStream(String userId) {
    return _db
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatModel.fromFirestore(d)).toList());
  }

  /// Crear o retornar chat existente entre dos usuarios
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String? currentUserPhoto,
    required String otherUserId,
    required String otherUserName,
    required String? otherUserPhoto,
    String? serviceId,
    String? serviceTitle,
  }) async {
    // Buscar si ya existe un chat entre estos dos usuarios
    final snap = await _db
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participantIds'] ?? []);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Crear nuevo chat
    final chatData = {
      'participantIds': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      'participantPhotos': {
        currentUserId: currentUserPhoto,
        otherUserId: otherUserPhoto,
      },
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'unreadCount': {currentUserId: 0, otherUserId: 0},
    };

    final ref = await _db.collection('chats').add(chatData);
    return ref.id;
  }

  /// Stream de mensajes de un chat
  Stream<List<MessageModel>> messagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromFirestore(d)).toList());
  }

  /// Enviar un mensaje
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    required String otherUserId,
  }) async {
    final batch = _db.batch();

    // Añadir mensaje
    final msgRef =
        _db.collection('chats').doc(chatId).collection('messages').doc();
    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Actualizar último mensaje y contador de no leídos
    final chatRef = _db.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': content,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount.$otherUserId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Marcar mensajes como leídos
  Future<void> markAsRead(String chatId, String userId) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .update({'unreadCount.$userId': 0});
  }

  // ────────────────────────────────────────────
  // USUARIOS
  // ────────────────────────────────────────────

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }
}
