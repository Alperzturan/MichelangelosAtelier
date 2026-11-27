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
                  const Divider(height: 32),
                  const Text(
                    'Eser Hakkında',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artwork.description.isNotEmpty
                        ? artwork.description
                        : 'Bu eser hakkında henüz detaylı açıklama eklenmemiştir.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
