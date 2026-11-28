import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/artwork_model.dart';
import 'package:mobile/models/review_model.dart';
import 'package:mobile/providers/review_provider.dart';
import 'package:mobile/services/api_service.dart';

class FakeReviewApiService extends ApiService {
  bool shouldFailFetch = false;
  bool shouldFailSubmit = false;
  String errorMessage = 'Hatalı işlem';

  final ArtworkModel mockArtwork = ArtworkModel(
    id: 1,
    title: 'Davud',
    artist: 'Michelangelo',
    year: 1504,
    imageUrl: 'https://example.com/david.jpg',
    description: 'Mermer heykel',
    categoryId: 1,
  );

  final List<ReviewModel> mockReviews = [
    ReviewModel(
      id: 101,
      userId: 1,
      artworkId: 1,
      rating: 5,
      comment: 'Muazzam bir başyapıt!',
      createdAt: DateTime.now(),
      userName: 'Orhan Yağız',
    ),
    ReviewModel(
      id: 102,
      userId: 2,
      artworkId: 1,
      rating: 3,
      comment: 'Detaylar güzel ama ışıklandırma zayıftı.',
      createdAt: DateTime.now(),
      userName: 'Ali Sanatsever',
    ),
  ];

  @override
  Future<ArtworkModel> fetchArtworkById(int artworkId) async {
    if (shouldFailFetch) throw Exception('Eser bulunamadı');
    return mockArtwork;
  }

  @override
  Future<List<ReviewModel>> fetchReviews({int? artworkId}) async {
    if (shouldFailFetch) throw Exception(errorMessage);
    return List<ReviewModel>.from(mockReviews);
  }

  @override
  Future<ReviewModel> createReview({
    required int artworkId,
    required int rating,
    required String comment,
  }) async {
    if (shouldFailSubmit) throw Exception(errorMessage);
    return ReviewModel(
      id: 103,
      userId: 1,
      artworkId: artworkId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      userName: 'Yeni Kullanıcı',
    );
  }
}

void main() {
  group('ReviewProvider Tests (5. Hafta Görevi - No: 23291238)', () {
    late FakeReviewApiService fakeApi;
    late ReviewProvider reviewProvider;

    setUp(() {
      fakeApi = FakeReviewApiService();
      reviewProvider = ReviewProvider(apiService: fakeApi);
    });

    test('1. Başlangıçta inceleme listesi boş, ortalama puan 0.0 ve isLoading == false olmalıdır', () {
      expect(reviewProvider.reviews, isEmpty);
      expect(reviewProvider.artworkDetail, isNull);
      expect(reviewProvider.averageRating, equals(0.0));
      expect(reviewProvider.isLoading, isFalse);
      expect(reviewProvider.isSubmitting, isFalse);
      expect(reviewProvider.errorMessage, isNull);
      expect(reviewProvider.submitError, isNull);
    });

    test('2. loadArtworkAndReviews eser detayını ve o esere ait incelemeleri yüklemelidir', () async {
      await reviewProvider.loadArtworkAndReviews(1);

      expect(reviewProvider.isLoading, isFalse);
      expect(reviewProvider.artworkDetail, isNotNull);
      expect(reviewProvider.artworkDetail?.title, equals('Davud'));
      expect(reviewProvider.reviews.length, equals(2));
      expect(reviewProvider.errorMessage, isNull);
    });

    test('3. averageRating incelemelerin puan ortalamasını doğru hesaplamalıdır', () async {
      await reviewProvider.loadArtworkAndReviews(1);

      // (5 + 3) / 2 = 4.0
      expect(reviewProvider.averageRating, equals(4.0));
      expect(reviewProvider.reviewCount, equals(2));
    });

    test('4. submitReview başarılı olduğunda yeni incelemeyi listenin başına eklemeli ve true döndürmelidir', () async {
      await reviewProvider.loadArtworkAndReviews(1);

      final success = await reviewProvider.submitReview(
        artworkId: 1,
        rating: 4,
        comment: 'Harika bir eser.',
      );

      expect(success, isTrue);
      expect(reviewProvider.isSubmitting, isFalse);
      expect(reviewProvider.reviews.length, equals(3));
      expect(reviewProvider.reviews.first.id, equals(103));
      expect(reviewProvider.reviews.first.rating, equals(4));
      // (4 + 5 + 3) / 3 = 4.0
      expect(reviewProvider.averageRating, equals(4.0));
    });

    test('5. Hata durumunda errorMessage / submitError atanmalı ve submitReview false döndürmelidir', () async {
      fakeApi.shouldFailFetch = true;
      fakeApi.errorMessage = 'Sunucuya ulaşılamadı';
      await reviewProvider.loadArtworkAndReviews(1);

      expect(reviewProvider.isLoading, isFalse);
      expect(reviewProvider.errorMessage, isNotNull);

      fakeApi.shouldFailSubmit = true;
      fakeApi.errorMessage = 'Yetkisiz erişim';
      final submitSuccess = await reviewProvider.submitReview(
        artworkId: 1,
        rating: 5,
        comment: 'Yorum',
      );

      expect(submitSuccess, isFalse);
      expect(reviewProvider.isSubmitting, isFalse);
      expect(reviewProvider.submitError, contains('Yetkisiz erişim'));
    });
  });
}
