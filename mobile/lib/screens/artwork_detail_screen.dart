import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artwork_model.dart';

class ArtworkDetailScreen extends StatelessWidget {
  const ArtworkDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final artwork = ModalRoute.of(context)?.settings.arguments as ArtworkModel?;

    if (artwork == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Eser Detayı')),
        body: const Center(
          child: Text('Görüntülenecek eser bilgisi bulunamadı.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(artwork.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Eser Görseli
            CachedNetworkImage(
              imageUrl: artwork.imageUrl,
              height: 320,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 320,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF5D4037)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 320,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
              ),
            ),

            // Eser Bilgileri
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.brush, size: 18, color: Color(0xFF5D4037)),
                      const SizedBox(width: 6),
                      Text(
                        artwork.artist,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          '${artwork.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFFD7CCC8),
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
          ],
        ),
      ),
    );
  }
}
