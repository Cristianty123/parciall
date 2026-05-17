// lib/core/storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class AppStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveSession({
    required String token,
    required String role,
    required String username,
  }) async {
    await _storage.write(key: AppConstants.keyToken, value: token);
    await _storage.write(key: AppConstants.keyRole, value: role);
    await _storage.write(key: AppConstants.keyUsername, value: username);
  }

  static Future<String?> getToken() =>
      _storage.read(key: AppConstants.keyToken);

  static Future<String?> getRole() =>
      _storage.read(key: AppConstants.keyRole);

  static Future<String?> getUsername() =>
      _storage.read(key: AppConstants.keyUsername);

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
