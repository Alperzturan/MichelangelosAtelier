import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // 3. Hafta: JWT Token'ı güvenli depolamaya kaydetme
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // 3. Hafta: JWT Token'ı güvenli depolamadan okuma
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // 3. Hafta: Oturum kapatıldığında JWT Token'ı silme
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Kullanıcı bilgilerini (JSON) saklama
  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _userKey, value: userDataJson);
  }

  // Saklanan kullanıcı bilgilerini okuma
  Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }

  // Tüm güvenli verileri temizleme
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
