import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artwork_model.dart';
import '../providers/gallery_provider.dart';

class GalleryHomeScreen extends StatefulWidget {
  const GalleryHomeScreen({super.key});

  @override
  State<GalleryHomeScreen> createState() => _GalleryHomeScreenState();
}

class _GalleryHomeScreenState extends State<GalleryHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gallery = Provider.of<GalleryProvider>(context, listen: false);
      if (gallery.artworks.isEmpty && !gallery.isLoading) {
        gallery.loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // 4. Hafta: Arama Çubuğu Debounce (~400ms) Tetikleyicisi
  void _onSearchChanged(String value, GalleryProvider galleryProvider) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      galleryProvider.setSearchQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gallery = Provider.of<GalleryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Michelangelo's Atelier"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: gallery.isLoading ? null : () => gallery.refresh(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4. Hafta: Arama Çubuğu (Search Bar) & Debounce (~400ms)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _onSearchChanged(value, gallery),
              decoration: InputDecoration(
                hintText: 'Eser başlığı veya sanatçı ara...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF5D4037)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          gallery.clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5D4037), width: 1.5),
                ),
              ),
            ),
          ),

          // 4. Hafta: Akım Seçim Çipleri (Category Chips - Yatayda Kaydırılabilir ChoiceChip)
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: gallery.categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = gallery.selectedCategoryId == null;
                  return ChoiceChip(
                    label: const Text('Tümü'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF5D4037),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => gallery.setCategory(null),
                  );
                }

                final category = gallery.categories[index - 1];
                final isSelected = gallery.selectedCategoryId == category.id;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  selectedColor: const Color(0xFF5D4037),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => gallery.setCategory(category.id),
                );
              },
            ),
          ),

          // Eser Sayısı Bilgisi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${gallery.artworkCount} Eser Listeleniyor',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // 4. Hafta: 2 Sütunlu Grid Eser Listeleme (GalleryProvider State ile)
          Expanded(
            child: gallery.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037)))
                : gallery.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                gallery.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5D4037),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => gallery.refresh(),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF5D4037),
                        onRefresh: () => gallery.refresh(),
                        child: gallery.artworks.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 80),
                                  Center(
                                    child: Text(
                                      'Arama veya kategori kriterine uygun eser bulunamadı.',
                                      style: TextStyle(fontSize: 15, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.62,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemCount: gallery.artworks.length,
                                itemBuilder: (context, index) {
                                  final artwork = gallery.artworks[index];
                                  return _ArtworkCard(artwork: artwork);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  final ArtworkModel artwork;

  const _ArtworkCard({required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/artwork-detail',
            arguments: artwork,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: artwork.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D4037)),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artwork.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7CCC8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${artwork.year}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
