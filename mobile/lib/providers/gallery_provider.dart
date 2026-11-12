import 'package:flutter/material.dart';
import '../models/artwork_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

// No: 23291238 State Yönetimi (Provider):
// Seçili aktif akımı, arama kutusundaki sorguyu ve anlık yüklenme/hata durumunu tutan galeri state mekanizması.
class GalleryProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<CategoryModel> _categories = [];
  List<ArtworkModel> _artworks = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  GalleryProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters
  List<CategoryModel> get categories => _categories;
  List<ArtworkModel> get artworks => _artworks;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  int get artworkCount => _artworks.length;

  // Başlangıç verilerini (kategoriler ve tüm eserler) yükleme
  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final categoriesFuture = _apiService.fetchCategories();
      final artworksFuture = _apiService.fetchArtworks(
        categoryId: _selectedCategoryId,
        query: _searchQuery,
      );

      final results = await Future.wait([categoriesFuture, artworksFuture]);

      _categories = results[0] as List<CategoryModel>;
      _artworks = results[1] as List<ArtworkModel>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Galeri verileri yüklenemedi. Sunucu bağlantınızı kontrol edin.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seçili sanat akımını (kategoriyi) değiştirme ve listeyi güncelleme
  Future<void> setCategory(int? categoryId) async {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null; // Zaten seçiliyse seçimi kaldır ("Tümü")
    } else {
      _selectedCategoryId = categoryId;
    }
    await fetchArtworks();
  }

  // Arama sorgusunu güncelleme ve listeyi filtreleme
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await fetchArtworks();
  }

  // Arama kutusunu temizleme
  Future<void> clearSearch() async {
    _searchQuery = '';
    await fetchArtworks();
  }

  // Backend'den filtrelenmiş eserleri çekme
  Future<void> fetchArtworks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.fetchArtworks(
        categoryId: _selectedCategoryId,
        query: _searchQuery,
        search: _searchQuery,
      );
      _artworks = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Filtrelenen eserler yüklenemedi.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tüm galeri verilerini yeniden yükleme (Pull-to-refresh)
  Future<void> refresh() async {
    await loadInitialData();
  }
}
