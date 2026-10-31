import 'package:flutter/material.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/artwork_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/gallery_home_screen.dart';
import 'screens/login_screen.dart';

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
        scaffoldBackgroundColor: const Color(0xFFFBF8F5),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF5D4037),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationScreen(),
        '/artwork-detail': (context) => const ArtworkDetailScreen(),
        '/register': (context) => const RegisterScreen(),
        '/artwork-form': (context) => const ArtworkFormScreen(),
      },
    );
  }
}

// 2. Hafta: Temel Navigasyon İskeleti (BottomNavigationBar)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    GalleryHomeScreen(),
    FavoritesScreen(),
    AdminDashboardScreen(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5D4037),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.museum), label: 'Galeri'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Atölyem'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Yönetim'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Giriş'),
        ],
      ),
    );
  }
}