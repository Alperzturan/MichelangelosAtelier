import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/artwork_model.dart';
import '../models/category_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String _tokenKey = 'jwt_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 3. Hafta: Flutter SecureStorage ile JWT Token saklama, okuma ve silme
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // 3. Hafta: Kullanıcı Girişi (/auth/login) ve Token Kaydetme
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'] as String;
      await saveToken(token);
      return token;
    } else {
      throw Exception('Giriş başarısız. E-posta veya şifre hatalı.');
    }
  }

  // 3. Hafta: Kullanıcı Kaydı (/auth/register)
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Kayıt işlemi başarısız oldu.');
    }
  }

  // Mevcut 2. Hafta Metotları
  Future<List<ArtworkModel>> fetchArtworks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/artworks'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((json) => ArtworkModel.fromJson(json)).toList();
    } else {
      throw Exception('Sanat eserleri yüklenemedi.');
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/categories'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Kategoriler yüklenemedi.');
    }
  }
}