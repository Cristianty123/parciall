import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registro de nuevo usuario
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? location,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      location: location,
    );

    await _db
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());

    return user;
  }

  // Inicio de sesión
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener perfil del usuario actual
  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  // Stream del perfil del usuario actual
  Stream<UserModel?> userProfileStream() {
    final uid = currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // Actualizar perfil
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? description,
    String? location,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (location != null) updates['location'] = location;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _db.collection('users').doc(uid).update(updates);
  }
}
