import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artwork_model.dart';
import '../models/category_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<ArtworkModel>> fetchArtworks() async {
    final response = await http.get(Uri.parse('$baseUrl/artworks'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((json) => ArtworkModel.fromJson(json)).toList();
    } else {
      throw Exception('Sanat eserleri yüklenemedi.');
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Kategoriler yüklenemedi.');
    }
  }
}