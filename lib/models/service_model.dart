import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String providerId;
  final String providerName;
  final String? providerPhotoUrl;
  final String price;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final String location;
  final bool active;
  final DateTime createdAt;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.providerId,
    required this.providerName,
    this.providerPhotoUrl,
    required this.price,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrls = const [],
    required this.location,
    this.active = true,
    required this.createdAt,
  });

  String get imageUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600';

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      providerPhotoUrl: data['providerPhotoUrl'],
      price: data['price'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      location: data['location'] ?? '',
      active: data['active'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'description': description,
        'providerId': providerId,
        'providerName': providerName,
        'providerPhotoUrl': providerPhotoUrl,
        'price': price,
        'rating': rating,
        'reviewCount': reviewCount,
        'imageUrls': imageUrls,
        'location': location,
        'active': active,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  ServiceModel copyWith({
    String? title,
    String? category,
    String? description,
    String? price,
    List<String>? imageUrls,
    String? location,
    bool? active,
    double? rating,
    int? reviewCount,
  }) {
    return ServiceModel(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      providerId: providerId,
      providerName: providerName,
      providerPhotoUrl: providerPhotoUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }
}
