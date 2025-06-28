import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final _storage = const FlutterSecureStorage();
  static final LocalStorageService _instance = LocalStorageService._internal();

  LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
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
