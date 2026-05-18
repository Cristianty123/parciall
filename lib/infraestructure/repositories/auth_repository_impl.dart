import 'package:dio/dio.dart';
import '../../data/interfaces/auth_repository_interface.dart';
import '../../data/models/user_model.dart';
import '../network/api_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _apiService.dio.post('/authenticate/login', data: {
        'username': username,
        'password': password,
      });
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(e.response?.data['message'] ?? "Usuario o contraseña incorrectos");
      }
      throw Exception("Error de conexión con el servidor");
    }
  }

  @override
  Future<UserModel> register(String username, String password, String role) async {
    try {
      final response = await _apiService.dio.post('/authenticate/register', data: {
        'username': username,
        'password': password,
        'role': role,
      });
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? "El nombre de usuario ya está en uso");
      }
      throw Exception("Error al registrar el usuario");
    }
  }
}