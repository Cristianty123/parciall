import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/interfaces/auth_repository_interface.dart';
import '../data/models/user_model.dart';
import 'package:parcial/infraestructure/repositories/auth_repository_impl.dart';

class AuthProvider with ChangeNotifier {
  final IAuthRepository _authRepository = AuthRepositoryImpl();
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(username, password);
      await _storage.write(key: 'jwt_token', value: _user!.token);
      await _storage.write(key: 'user_role', value: _user!.role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.register(username, password, role);
      await _storage.write(key: 'jwt_token', value: _user!.token);
      await _storage.write(key: 'user_role', value: _user!.role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    _user = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');
    if (token != null && role != null) {
      _user = UserModel(username: '', role: role, token: token);
      notifyListeners();
      return true;
    }
    return false;
  }
}
