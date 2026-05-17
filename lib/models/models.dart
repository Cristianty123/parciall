// lib/models/models.dart

// ── Auth ──────────────────────────────────────────────────────────────

class LoginResponse {
  final bool success;
  final String? token;
  final String? username;
  final String? role;
  final String? message;

  LoginResponse({
    required this.success,
    this.token,
    this.username,
    this.role,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> j) => LoginResponse(
        success: j['success'] ?? false,
        token: j['token'],
        username: j['username'],
        role: j['role'],
        message: j['message'],
      );
}

// ── User ──────────────────────────────────────────────────────────────

class UserProfile {
  final int id;
  final String username;
  final String role;
  final String? fullName;
  final String? photoUrl;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;

  UserProfile({
    required this.id,
    required this.username,
    required this.role,
    this.fullName,
    this.photoUrl,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'],
        username: j['username'],
        role: j['role'],
        fullName: j['fullName'],
        photoUrl: j['photoUrl'],
        description: j['description'],
        address: j['address'],
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
      );
}

class EntrepreneurProfile {
  final int id;
  final String? fullName;
  final String? photoUrl;
  final String? description;
  final String? address;
  final double averageRating;
  final int totalReviews;

  EntrepreneurProfile({
    required this.id,
    this.fullName,
    this.photoUrl,
    this.description,
    this.address,
    required this.averageRating,
    required this.totalReviews,
  });

  factory EntrepreneurProfile.fromJson(Map<String, dynamic> j) =>
      EntrepreneurProfile(
        id: j['id'],
        fullName: j['fullName'],
        photoUrl: j['photoUrl'],
        description: j['description'],
        address: j['address'],
        averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: j['totalReviews'] ?? 0,
      );
}

// ── Category ──────────────────────────────────────────────────────────

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: j['id'], name: j['name']);
}

// ── Service ───────────────────────────────────────────────────────────

class ServiceCard {
  final int id;
  final String title;
  final String? description;
  final double? price;
  final String? categoryName;
  final String? entrepreneurFullName;
  final String? entrepreneurPhotoUrl;
  final int entrepreneurId;
  final List<String> imageUrls;
  final double averageRating;
  final int totalReviews;

  ServiceCard({
    required this.id,
    required this.title,
    this.description,
    this.price,
    this.categoryName,
    this.entrepreneurFullName,
    this.entrepreneurPhotoUrl,
    required this.entrepreneurId,
    required this.imageUrls,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ServiceCard.fromJson(Map<String, dynamic> j) => ServiceCard(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        price: (j['price'] as num?)?.toDouble(),
        categoryName: j['categoryName'],
        entrepreneurFullName: j['entrepreneurFullName'],
        entrepreneurPhotoUrl: j['entrepreneurPhotoUrl'],
        entrepreneurId: j['entrepreneurId'] ?? 0,
        imageUrls: List<String>.from(j['imageUrls'] ?? []),
        averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: j['totalReviews'] ?? 0,
      );
}

class ServiceDetail {
  final int id;
  final String title;
  final String? description;
  final double? price;
  final String status;
  final String? categoryName;
  final int entrepreneurId;
  final String? entrepreneurFullName;
  final String? entrepreneurPhotoUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final double averageRating;
  final int totalReviews;

  ServiceDetail({
    required this.id,
    required this.title,
    this.description,
    this.price,
    required this.status,
    this.categoryName,
    required this.entrepreneurId,
    this.entrepreneurFullName,
    this.entrepreneurPhotoUrl,
    this.address,
    this.latitude,
    this.longitude,
    required this.imageUrls,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> j) => ServiceDetail(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        price: (j['price'] as num?)?.toDouble(),
        status: j['status'] ?? 'ACTIVE',
        categoryName: j['categoryName'],
        entrepreneurId: j['entrepreneurId'] ?? 0,
        entrepreneurFullName: j['entrepreneurFullName'],
        entrepreneurPhotoUrl: j['entrepreneurPhotoUrl'],
        address: j['address'],
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        imageUrls: List<String>.from(j['imageUrls'] ?? []),
        averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: j['totalReviews'] ?? 0,
      );
}

class ServiceSummary {
  final int id;
  final String title;
  final String? description;
  final double? price;
  final String status;
  final String? categoryName;
  final List<String> imageUrls;

  ServiceSummary({
    required this.id,
    required this.title,
    this.description,
    this.price,
    required this.status,
    this.categoryName,
    required this.imageUrls,
  });

  factory ServiceSummary.fromJson(Map<String, dynamic> j) => ServiceSummary(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        price: (j['price'] as num?)?.toDouble(),
        status: j['status'] ?? 'ACTIVE',
        categoryName: j['categoryName'],
        imageUrls: List<String>.from(j['imageUrls'] ?? []),
      );
}

class ServiceMapMarker {
  final int id;
  final String title;
  final double latitude;
  final double longitude;
  final String? category;
  final String? entrepreneurFullName;

  ServiceMapMarker({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.category,
    this.entrepreneurFullName,
  });

  factory ServiceMapMarker.fromJson(Map<String, dynamic> j) =>
      ServiceMapMarker(
        id: j['id'],
        title: j['title'] ?? '',
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        category: j['category'],
        entrepreneurFullName: j['entrepreneurFullName'],
      );
}

// ── Paged ─────────────────────────────────────────────────────────────

class PagedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  PagedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) fromItem,
  ) =>
      PagedResponse(
        content: (j['content'] as List).map((e) => fromItem(e)).toList(),
        totalElements: j['totalElements'] ?? 0,
        totalPages: j['totalPages'] ?? 0,
        currentPage: j['currentPage'] ?? 0,
      );
}

// ── Chat ──────────────────────────────────────────────────────────────

class ConversationItem {
  final int partnerId;
  final String? partnerName;
  final String? partnerPhoto;
  final String? lastMessage;
  final String? lastMessageAt;
  final int unreadCount;

  ConversationItem({
    required this.partnerId,
    this.partnerName,
    this.partnerPhoto,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> j) =>
      ConversationItem(
        partnerId: j['partnerId'],
        partnerName: j['partnerName'],
        partnerPhoto: j['partnerPhoto'],
        lastMessage: j['lastMessage'],
        lastMessageAt: j['lastMessageAt'],
        unreadCount: j['unreadCount'] ?? 0,
      );
}

class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String sentAt;
  final bool read;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    required this.read,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'],
        senderId: j['senderId'],
        receiverId: j['receiverId'],
        content: j['content'] ?? '',
        sentAt: j['sentAt'] ?? '',
        read: j['read'] ?? false,
      );
}

// ── Reviews ───────────────────────────────────────────────────────────

class ReviewItem {
  final double rating;
  final String? comment;
  final String? createdAt;
  final String? clientFullName;
  final String? clientPhotoUrl;
  final String? serviceTitle;

  ReviewItem({
    required this.rating,
    this.comment,
    this.createdAt,
    this.clientFullName,
    this.clientPhotoUrl,
    this.serviceTitle,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(
        rating: (j['rating'] as num).toDouble(),
        comment: j['comment'],
        createdAt: j['createdAt'],
        clientFullName: j['client']?['fullName'],
        clientPhotoUrl: j['client']?['photoUrl'],
        serviceTitle: j['servicePost']?['title'],
      );
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> distribution;

  ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> j) => ReviewSummary(
        averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: j['totalReviews'] ?? 0,
        distribution: Map<String, int>.from(
          (j['distribution'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, (v as num).toInt()),
              ) ??
              {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
        ),
      );
}
