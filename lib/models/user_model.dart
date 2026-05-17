import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'cliente' | 'emprendedor'
  final String? photoUrl;
  final String? description;
  final String? location;
  final double averageRating;
  final int reviewCount;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.description,
    this.location,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  bool get isEmprendedor => role == 'emprendedor';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'cliente',
      photoUrl: data['photoUrl'],
      description: data['description'],
      location: data['location'],
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': photoUrl,
        'description': description,
        'location': location,
        'averageRating': averageRating,
        'reviewCount': reviewCount,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? description,
    String? location,
    double? averageRating,
    int? reviewCount,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      location: location ?? this.location,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
