import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/artwork_model.dart';
import 'package:mobile/models/category_model.dart';
import 'package:mobile/providers/gallery_provider.dart';
import 'package:mobile/services/api_service.dart';

// Mock ApiService for Gallery tests
class FakeGalleryApiService extends ApiService {
  bool shouldFail = false;
  int? lastCategoryId;
  String? lastQuery;

  final List<CategoryModel> mockCategories = [
    CategoryModel(id: 1, name: 'Yüksek Rönesans', description: 'Rönesans sanatı'),
    CategoryModel(id: 2, name: 'Barok', description: 'Barok sanatı'),
  ];

  final List<ArtworkModel> mockArtworks = [
    ArtworkModel(
      id: 1,
      title: 'Davud',
      artist: 'Michelangelo',
      year: 1504,
      imageUrl: 'https://example.com/david.jpg',
      description: 'Mermer heykel',
      categoryId: 1,
    ),
    ArtworkModel(
      id: 2,
      title: 'Aziz Matta',
      artist: 'Caravaggio',
      year: 1600,
      imageUrl: 'https://example.com/matthew.jpg',
      description: 'Barok tablo',
      categoryId: 2,
    ),
  ];

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    if (shouldFail) throw Exception('Kategori hatası');
    return mockCategories;
  }

  @override
  Future<List<ArtworkModel>> fetchArtworks({
    int? categoryId,
    String? query,
    String? search,
  }) async {
    if (shouldFail) throw Exception('Eser hatası');
    lastCategoryId = categoryId;
    lastQuery = query ?? search;

    var filtered = mockArtworks;
    if (categoryId != null) {
      filtered = filtered.where((a) => a.categoryId == categoryId).toList();
    }
    if (lastQuery != null && lastQuery!.isNotEmpty) {
      filtered = filtered
          .where((a) =>
              a.title.toLowerCase().contains(lastQuery!.toLowerCase()) ||
              a.artist.toLowerCase().contains(lastQuery!.toLowerCase()))
          .toList();
    }
    return filtered;
  }
}

void main() {
  group('GalleryProvider Tests (No: 23291238 State Yönetimi)', () {
    late FakeGalleryApiService fakeApi;
    late GalleryProvider galleryProvider;

    setUp(() {
      fakeApi = FakeGalleryApiService();
      galleryProvider = GalleryProvider(apiService: fakeApi);
    });

    test('Başlangıçta kategori ve eser listesi boş olmalıdır', () {
      expect(galleryProvider.categories, isEmpty);
      expect(galleryProvider.artworks, isEmpty);
      expect(galleryProvider.selectedCategoryId, isNull);
      expect(galleryProvider.searchQuery, isEmpty);
      expect(galleryProvider.isLoading, isFalse);
    });

    test('loadInitialData kategorileri ve eserleri yüklemelidir', () async {
      await galleryProvider.loadInitialData();

      expect(galleryProvider.isLoading, isFalse);
      expect(galleryProvider.categories.length, equals(2));
      expect(galleryProvider.artworks.length, equals(2));
      expect(galleryProvider.hasError, isFalse);
    });

    test('setCategory seçili akımı güncellemeli ve filtrelemelidir', () async {
      await galleryProvider.loadInitialData();
      await galleryProvider.setCategory(1);

      expect(galleryProvider.selectedCategoryId, equals(1));
      expect(galleryProvider.artworks.length, equals(1));
      expect(galleryProvider.artworks.first.title, equals('Davud'));
      expect(fakeApi.lastCategoryId, equals(1));

      // Aynı kategoriye tekrar tıklanırsa "Tümü"ne dönmelidir
      await galleryProvider.setCategory(1);
      expect(galleryProvider.selectedCategoryId, isNull);
      expect(galleryProvider.artworks.length, equals(2));
    });

    test('setSearchQuery arama sorgusunu güncellemeli ve filtrelemelidir', () async {
      await galleryProvider.loadInitialData();
      await galleryProvider.setSearchQuery('Caravaggio');

      expect(galleryProvider.searchQuery, equals('Caravaggio'));
      expect(galleryProvider.artworks.length, equals(1));
      expect(galleryProvider.artworks.first.artist, equals('Caravaggio'));
      expect(fakeApi.lastQuery, equals('Caravaggio'));
    });

    test('clearSearch arama sorgusunu sıfırlamalıdır', () async {
      await galleryProvider.loadInitialData();
      await galleryProvider.setSearchQuery('Davud');
      expect(galleryProvider.artworks.length, equals(1));

      await galleryProvider.clearSearch();
      expect(galleryProvider.searchQuery, isEmpty);
      expect(galleryProvider.artworks.length, equals(2));
    });

    test('Hata durumunda errorMessage atanmalıdır', () async {
      fakeApi.shouldFail = true;
      await galleryProvider.loadInitialData();

      expect(galleryProvider.isLoading, isFalse);
      expect(galleryProvider.hasError, isTrue);
      expect(galleryProvider.errorMessage, isNotNull);
    });
  });
}
