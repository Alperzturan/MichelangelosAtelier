import 'package:flutter/material.dart';

void main() {
  runApp(const MichelangelosAtelierApp());
}

class MichelangelosAtelierApp extends StatelessWidget {
  const MichelangelosAtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Michelangelo's Atelier",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D6E63)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Michelangelo's Atelier"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.museum_outlined,
                size: 80,
                color: Color(0xFF8D6E63),
              ),
              const SizedBox(height: 20),
              const Text(
                "Michelangelo's Atelier",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Dijital Sanat Galerisi ve Koleksiyon Yönetimi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}