import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LocalStorageService {
  final _storage = const FlutterSecureStorage();
  static final LocalStorageService _instance = LocalStorageService._internal();

  LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }
  Future<String> getUserRole()async{
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception("No authentication token found");
    }
    final decoded = JwtDecoder.decode(token);
    final role = decoded['role'] ?? decoded['userRole'];
    if (role == null) {
      throw Exception("Role not found in token");
    }
    return role;
  }
  Future<String> getUserId() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception("No authentication token found");
    }
    final decoded =  JwtDecoder.decode(token);
    final userId = decoded['userId'] ?? decoded['id'];
    return userId;
  }

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
