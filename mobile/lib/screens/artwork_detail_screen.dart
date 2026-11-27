import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artwork_model.dart';
import '../models/category_model.dart';
import '../providers/gallery_provider.dart';

class ArtworkDetailScreen extends StatelessWidget {
  final ArtworkModel? initialArtwork;

  const ArtworkDetailScreen({super.key, this.initialArtwork});

  String? _resolveCategoryName(BuildContext context, int categoryId) {
    try {
      final gallery = Provider.of<GalleryProvider>(context, listen: false);
      for (final CategoryModel category in gallery.categories) {
        if (category.id == categoryId) {
          return category.name;
        }
      }
    } catch (_) {
      // Provider ağacı dışında test edilirse güvenli şekilde null döner
    }
    return null;
  }

  void _openFullScreenImage(BuildContext context, ArtworkModel artwork) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (dialogContext) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              artwork.title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Hero(
                tag: 'artwork-image-${artwork.id}',
                child: CachedNetworkImage(
                  imageUrl: artwork.imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    size: 72,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArtwork = ModalRoute.of(context)?.settings.arguments as ArtworkModel?;
    final artwork = initialArtwork ?? routeArtwork;

    if (artwork == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Eser Detayı')),
        body: const Center(
          child: Text('Görüntülenecek eser bilgisi bulunamadı.'),
        ),
      );
    }

    final categoryName = _resolveCategoryName(context, artwork.categoryId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 5. Hafta - Görev 1: Hero Animasyonlu Büyük Görsel & Daralabilir Üst Başlık
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF5D4037),
            foregroundColor: Colors.white,
            title: Text(
              artwork.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = MediaQuery.of(context).padding.top;
                final minHeight = kToolbarHeight + topPadding;
                const maxHeight = 360.0;
                final expandRatio = ((constraints.maxHeight - minHeight) /
                        (maxHeight - minHeight))
                    .clamp(0.0, 1.0);
                final collapsedOverlayAlpha = 0.55 * (1.0 - expandRatio);

                return GestureDetector(
                  onTap: expandRatio > 0.25
                      ? () => _openFullScreenImage(context, artwork)
                      : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'artwork-image-${artwork.id}',
                        child: CachedNetworkImage(
                          imageUrl: artwork.imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFEDE7E3),
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF5D4037)),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        ),
                      ),
                      // Genişken üst/alt okunabilirlik gradyanı, daraldıkça başlık arkası koyulaştırma
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.black.withValues(alpha: collapsedOverlayAlpha),
                              Colors.black.withValues(alpha: collapsedOverlayAlpha),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                            stops: const [0.0, 0.28, 0.72, 1.0],
                          ),
                        ),
                      ),
                      if (expandRatio > 0.15)
                        Positioned(
                          right: 14,
                          bottom: 14,
                          child: Opacity(
                            opacity: expandRatio,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in, size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Yakınlaştır',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Eser Temel Bilgileri
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D4037),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7CCC8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history_edu, size: 15, color: Color(0xFF3E2723)),
                            const SizedBox(width: 5),
                            Text(
                              '${artwork.year}',
                              style: const TextStyle(
                                color: Color(0xFF3E2723),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    artwork.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.brush, size: 18, color: Color(0xFF5D4037)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          artwork.artist,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Hafta - Görev 2: Zenginleştirilmiş Eser Hakkında Kartı
                  _ArtworkDescriptionCard(description: artwork.description),
                  const SizedBox(height: 16),

                  // 5. Hafta - Görev 2: Sanatçı Biyografisi Kartı
                  _ArtistBiographyCard(
                    artistName: artwork.artist,
                    artworkYear: artwork.year,
                    categoryName: categoryName,
                    customBio: artwork.artistBio,
                    customPeriod: artwork.artistPeriod,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkDescriptionCard extends StatelessWidget {
  final String description;

  const _ArtworkDescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DDD8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E2723).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 20, color: Color(0xFF5D4037)),
              SizedBox(width: 8),
              Text(
                'Eser Hakkında',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty
                ? description
                : 'Bu eser hakkında henüz detaylı açıklama eklenmemiştir.',
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistProfile {
  final String period;
  final String biography;

  const _ArtistProfile({
    required this.period,
    required this.biography,
  });
}

class _ArtistBiographyCard extends StatelessWidget {
  final String artistName;
  final int artworkYear;
  final String? categoryName;
  final String? customBio;
  final String? customPeriod;

  const _ArtistBiographyCard({
    required this.artistName,
    required this.artworkYear,
    this.categoryName,
    this.customBio,
    this.customPeriod,
  });

  static const Map<String, _ArtistProfile> _curatedBiographies = {
    'michelangelo': _ArtistProfile(
      period: '1475 – 1564 • Yüksek Rönesans',
      biography:
          'İtalyan Yüksek Rönesansının en büyük heykeltıraş, ressam ve mimarlarından biridir. '
          'Floransa ve Roma\'da ürettiği Davud, Pietà ve Sistine Şapeli freskleriyle insan anatomisine '
          'duygusal güç ve anıtsal bir dinamizm kazandırmıştır.',
    ),
    'leonardo da vinci': _ArtistProfile(
      period: '1452 – 1519 • Yüksek Rönesans',
      biography:
          'Rönesansın "Evrensel İnsanı" olarak anılan Leonardo da Vinci; ressam, mucit, anatomist ve mühendistir. '
          'Sfumato ışık-gölge geçişleri ve bilimsel gözlem gücüyle Mona Lisa ve Son Akşam Yemeği gibi '
          'sanat tarihinin yönünü değiştiren başyapıtlara imza atmıştır.',
    ),
    'raffaello': _ArtistProfile(
      period: '1483 – 1520 • Yüksek Rönesans',
      biography:
          'Uyum, zarafet ve kusursuz perspektif anlayışıyla tanınan İtalyan Yüksek Rönesans ustasıdır. '
          'Vatikan odalarındaki Atina Okulu başta olmak üzere anıtsal freskleri, klasik felsefe ile '
          'Rönesans idealizmini benzersiz bir dengede buluşturur.',
    ),
    'caravaggio': _ArtistProfile(
      period: '1571 – 1610 • Barok',
      biography:
          'Barok resmin öncüsü kabul edilen Michelangelo Merisi da Caravaggio, dramatik ışık-gölge '
          'kontrastı (chiaroscuro / tenebrizm) ve çarpıcı gerçekçiliğiyle Avrupa resim sanatında '
          'devrim yaratmıştır.',
    ),
    'botticelli': _ArtistProfile(
      period: '1445 – 1510 • Erken Rönesans',
      biography:
          'Floransa Rönesansının zarif çizgileri ve mitolojik anlatılarıyla öne çıkan ustasıdır. '
          'Venüs\'ün Doğuşu ve İlkbahar gibi eserleriyle lirik bir estetik dil geliştirmiştir.',
    ),
    'bernini': _ArtistProfile(
      period: '1598 – 1680 • Barok',
      biography:
          'Barok heykel ve mimarinin en etkili ismi olan Gian Lorenzo Bernini, mermere hareket ve '
          'tiyatral duygu kazandıran eserleriyle Roma\'nın sanatsal çehresini şekillendirmiştir.',
    ),
    'rembrandt': _ArtistProfile(
      period: '1606 – 1669 • Hollanda Altın Çağı / Barok',
      biography:
          'Işık ve psikolojik derinlik ustası Hollandalı ressam Rembrandt van Rijn, portreleri ve '
          'tarihsel kompozisyonlarında insan ruhunun en ince ifadelerini tuvale aktarmıştır.',
    ),
  };

  _ArtistProfile _resolveProfile() {
    final normalized = artistName.toLowerCase().trim();
    final hasCustomPeriod = customPeriod != null && customPeriod!.trim().isNotEmpty;
    final hasCustomBio = customBio != null && customBio!.trim().isNotEmpty;

    for (final entry in _curatedBiographies.entries) {
      if (normalized.contains(entry.key)) {
        return _ArtistProfile(
          period: hasCustomPeriod ? customPeriod!.trim() : entry.value.period,
          biography: hasCustomBio ? customBio!.trim() : entry.value.biography,
        );
      }
    }

    final fallbackPeriod = hasCustomPeriod
        ? customPeriod!.trim()
        : (categoryName != null
            ? '$categoryName • $artworkYear dönemi'
            : '$artworkYear dönemi sanatçısı');

    final fallbackBio = hasCustomBio
        ? customBio!.trim()
        : '$artistName, $artworkYear yılı dolaylarında ürettiği çalışmalarla koleksiyonumuzda yer alan '
            've döneminin üslubunu yansıtan seçkin sanatçılardan biridir.';

    return _ArtistProfile(period: fallbackPeriod, biography: fallbackBio);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _resolveProfile();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin_rounded, size: 20, color: Color(0xFF5D4037)),
              SizedBox(width: 8),
              Text(
                'Sanatçı Biyografisi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF5D4037),
                child: Text(
                  _initials(artistName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artistName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.period,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.biography,
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Colors.grey[850],
            ),
          ),
        ],
      ),
    );
  }
}
