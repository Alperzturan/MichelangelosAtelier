import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artwork_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class GalleryHomeScreen extends StatefulWidget {
  const GalleryHomeScreen({super.key});

  @override
  State<GalleryHomeScreen> createState() => _GalleryHomeScreenState();
}

class _GalleryHomeScreenState extends State<GalleryHomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<CategoryModel> _categories = [];
  List<ArtworkModel> _artworks = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoriesFuture = _apiService.fetchCategories();
      final artworksFuture = _apiService.fetchArtworks(
        categoryId: _selectedCategoryId,
        query: _searchQuery,
      );

      final results = await Future.wait([categoriesFuture, artworksFuture]);

      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<CategoryModel>;
        _artworks = results[1] as List<ArtworkModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Galeri verileri yüklenemedi. Sunucu bağlantınızı kontrol edin.';
        _isLoading = false;
      });
    }
  }

  Future<void> _filterArtworks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final artworks = await _apiService.fetchArtworks(
        categoryId: _selectedCategoryId,
        query: _searchQuery,
      );
      if (!mounted) return;
      setState(() {
        _artworks = artworks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Filtrelenen eserler yüklenemedi.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _searchQuery = value);
      _filterArtworks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Michelangelo's Atelier"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4. Hafta: Dinamik Arama Çubuğu (?q= parametresi ile)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Eser başlığı veya sanatçı ara...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF5D4037)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _filterArtworks();
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
          // 4. Hafta: Sanat Akımı Seçim Çipleri (?category_id= parametresi ile)
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategoryId == null;
                  return ChoiceChip(
                    label: const Text('Tüm Eserler'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF5D4037),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategoryId = null);
                      _filterArtworks();
                    },
                  );
                }

                final category = _categories[index - 1];
                final isSelected = _selectedCategoryId == category.id;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  selectedColor: const Color(0xFF5D4037),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryId = isSelected ? null : category.id;
                    });
                    _filterArtworks();
                  },
                );
              },
            ),
          ),
          // 4. Hafta: 2 Sütunlu Grid Eser Listeleme
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037)))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadInitialData,
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF5D4037),
                        onRefresh: _loadInitialData,
                        child: _artworks.isEmpty
                            ? const Center(
                                child: Text('Arama veya kategori kriterine uygun eser bulunamadı.'),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.62,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemCount: _artworks.length,
                                itemBuilder: (context, index) {
                                  final artwork = _artworks[index];
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