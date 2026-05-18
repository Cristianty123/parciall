import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(String username, String password, String role);
}