import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yönetici Paneli')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/artwork-form'),
          child: const Text('Eser Formu İskeletine Git'),
        ),
      ),
    );
  }
}

class ArtworkFormScreen extends StatelessWidget {
  const ArtworkFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eser Ekle / Düzenle')),
      body: const Center(
        child: Text('ArtworkFormScreen İskeleti'),
      ),
    );
  }
}