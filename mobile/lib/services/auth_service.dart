import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  // 3. Hafta: Kullanıcı Girişi ve HTTP Hata Kodlarının (400, 401, 422) İşlenmesi
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/login-json');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['access_token'] as String;
    } else if (response.statusCode == 401) {
      throw const AuthException('Geçersiz e-posta veya şifre.');
    } else if (response.statusCode == 400) {
      final errorData = _parseError(response.body);
      throw AuthException(errorData ?? 'Hatalı giriş isteği.');
    } else if (response.statusCode == 422) {
      throw const AuthException('Girilen veriler doğrulanamadı. Lütfen alanları kontrol edin.');
    } else {
      throw AuthException('Sunucu hatası oluştu (${response.statusCode}). Lütfen tekrar deneyin.');
    }
  }

  // 3. Hafta: Kullanıcı Kaydı ve HTTP Hata Kodlarının (400, 422) İşlenmesi
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/register');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return UserModel.fromJson(data);
    } else if (response.statusCode == 400) {
      final errorData = _parseError(response.body);
      throw AuthException(errorData ?? 'Bu e-posta adresi ile kayıtlı bir kullanıcı zaten mevcut.');
    } else if (response.statusCode == 422) {
      throw const AuthException('Form verileri doğrulanamadı. Şifre en az 6 karakter olmalıdır.');
    } else {
      throw AuthException('Kayıt işlemi başarısız oldu (${response.statusCode}).');
    }
  }

  // 3. Hafta: Giriş Yapmış Kullanıcı Bilgisini Getirme (/auth/me)
  Future<UserModel> getCurrentUser(String token) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/me');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return UserModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw const AuthException('Oturum süresi dolmuş veya token geçersiz.');
    } else {
      throw AuthException('Kullanıcı bilgisi alınamadı (${response.statusCode}).');
    }
  }

  String? _parseError(String body) {
    try {
      final data = json.decode(body);
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
    } catch (_) {}
    return null;
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
