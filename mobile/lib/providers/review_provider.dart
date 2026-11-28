import 'package:flutter/material.dart';
import '../models/artwork_model.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';

// No: 23291238 State Yönetimi (Provider):
// 5. Hafta: Eser detayı ve eleştiri/puanlama (GET/POST /reviews) durumlarını yöneten Provider.
class ReviewProvider extends ChangeNotifier {
  final ApiService _apiService;

  ArtworkModel? _artworkDetail;
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _submitError;

  ReviewProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  ArtworkModel? get artworkDetail => _artworkDetail;
  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get submitError => _submitError;
  int get reviewCount => _reviews.length;

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, item) => sum + item.rating);
    return total / _reviews.length;
  }

  Future<void> loadArtworkAndReviews(
    int artworkId, {
    ArtworkModel? fallbackArtwork,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _submitError = null;
    _artworkDetail = fallbackArtwork;
    notifyListeners();

    try {
      // Eser detayı uç noktası henüz aktif değilse fallbackArtwork korunur
      try {
        _artworkDetail = await _apiService.fetchArtworkById(artworkId);
      } catch (_) {
        _artworkDetail = fallbackArtwork;
      }

      _reviews = await _apiService.fetchReviews(artworkId: artworkId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Değerlendirmeler yüklenemedi. Sunucu bağlantınızı kontrol edin.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int artworkId,
    required int rating,
    required String comment,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final created = await _apiService.createReview(
        artworkId: artworkId,
        rating: rating,
        comment: comment,
      );
      _reviews = [created, ..._reviews];
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _submitError = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearErrors() {
    _errorMessage = null;
    _submitError = null;
    notifyListeners();
  }
}
