import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/artwork_model.dart';
import '../models/category_model.dart';
import '../models/review_model.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService;

  ApiService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  // 3. Hafta: StorageService üzerinden JWT Token saklama, okuma ve silme
  Future<void> saveToken(String token) async {
    await _storageService.saveToken(token);
  }

  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  Future<void> deleteToken() async {
    await _storageService.deleteToken();
  }

  // 3. Hafta: Kullanıcı Girişi (/auth/login) ve Token Kaydetme
  Future<String> login({
    required String email,
    required String password,
  }) async {
    var uri = Uri.parse('$baseUrl/api/v1/auth/login');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 404) {
      uri = Uri.parse('$baseUrl/auth/login');
      response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final token = data['access_token'];
      if (token != null) {
        await saveToken(token);
        return token;
      } else {
        throw Exception('Token alınamadı.');
      }
    } else {
      throw Exception('Giriş başarısız: ${response.statusCode}');
    }
  }

  // 4. Hafta: Kategori (category_id) ve Arama (q) destekli eser listeleme (/api/v1/artworks/?category_id=&q=)
  Future<List<ArtworkModel>> fetchArtworks({
    int? categoryId,
    String? query,
    String? search,
  }) async {
    final effectiveQuery = (query != null && query.trim().isNotEmpty)
        ? query.trim()
        : (search != null && search.trim().isNotEmpty ? search.trim() : null);

    final Map<String, String> queryParams = {};
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }
    if (effectiveQuery != null) {
      queryParams['q'] = effectiveQuery;
    }

    final uri = Uri.parse('$baseUrl/api/v1/artworks/').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => ArtworkModel.fromJson(item)).toList();
    } else {
      throw Exception('Sanat eserleri yüklenemedi.');
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/categories/'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => CategoryModel.fromJson(item)).toList();
    } else {
      throw Exception('Kategoriler yüklenemedi.');
    }
  }

  // 5. Hafta: Tekil Eser Detayı (/api/v1/artworks/{id})
  Future<ArtworkModel> fetchArtworkById(int artworkId) async {
    final uri = Uri.parse('$baseUrl/api/v1/artworks/$artworkId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ArtworkModel.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Sanat eseri bulunamadı.');
    } else {
      throw Exception('Eser detayı yüklenemedi (${response.statusCode}).');
    }
  }

  // 5. Hafta: Eser İncelemelerini Listeleme (/api/v1/reviews/?artwork_id=)
  Future<List<ReviewModel>> fetchReviews({int? artworkId}) async {
    final Map<String, String> queryParams = {};
    if (artworkId != null) {
      queryParams['artwork_id'] = artworkId.toString();
    }

    final uri = Uri.parse('$baseUrl/api/v1/reviews/').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Iterable data = json.decode(utf8.decode(response.bodyBytes));
      var reviews = data.map((item) => ReviewModel.fromJson(item)).toList();
      // Backend query parametresini henüz filtrelemiyorsa istemci tarafında da güvence altına al
      if (artworkId != null) {
        reviews = reviews.where((r) => r.artworkId == artworkId).toList();
      }
      return reviews;
    } else {
      throw Exception('Değerlendirmeler yüklenemedi (${response.statusCode}).');
    }
  }

  // 5. Hafta: Yeni İnceleme ve 1-5 Yıldız Puanı Gönderme (JWT Korumalı POST /api/v1/reviews/)
  Future<ReviewModel> createReview({
    required int artworkId,
    required int rating,
    required String comment,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Değerlendirme yapmak için giriş yapmanız gerekiyor.');
    }

    final uri = Uri.parse('$baseUrl/api/v1/reviews/');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'artwork_id': artworkId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ReviewModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');
    } else {
      throw Exception('Değerlendirme gönderilemedi (${response.statusCode}).');
    }
  }
}
