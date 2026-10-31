import 'package:flutter/material.dart';

class ArtworkDetailScreen extends StatelessWidget {
  const ArtworkDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eser Detay Ekranı')),
      body: const Center(
        child: Text('ArtworkDetailScreen İskeleti'),
      ),
    );
  }
}