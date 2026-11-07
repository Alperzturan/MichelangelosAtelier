import 'package:flutter/material.dart';

class GalleryHomeScreen extends StatelessWidget {
  const GalleryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Michelangelo's Atelier")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/artwork-detail'),
          child: const Text('Eser Detay İskeletine Git'),
        ),
      ),
    );
  }
}
