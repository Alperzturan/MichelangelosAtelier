import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/artwork_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/gallery_home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MichelangelosAtelierApp());
}

class MichelangelosAtelierApp extends StatelessWidget {
  const MichelangelosAtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: MaterialApp(
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
      ),
    );
  }
}

// 2. & 3. Hafta: Temel Navigasyon İskeleti ve Auth Durumu Entegrasyonu
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    final List<Widget> screens = [
      const GalleryHomeScreen(),
      const FavoritesScreen(),
      const AdminDashboardScreen(),
      isLoggedIn
          ? _UserProfileView(onLogout: () => setState(() => _selectedIndex = 0))
          : LoginScreen(onLoginSuccess: () => setState(() => _selectedIndex = 0)),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5D4037),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.museum), label: 'Galeri'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Atölyem'),
          const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Yönetim'),
          BottomNavigationBarItem(
            icon: Icon(isLoggedIn ? Icons.account_circle : Icons.person),
            label: isLoggedIn ? 'Profil' : 'Giriş',
          ),
        ],
      ),
    );
  }
}

// Giriş Yapmış Kullanıcı Profil Kartı & Çıkış Yap Arayüzü
class _UserProfileView extends StatelessWidget {
  final VoidCallback onLogout;
  const _UserProfileView({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Profili')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFF5D4037),
                child: Text(
                  user != null && user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Kullanıcı',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                user?.email ?? '',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Chip(
                label: Text(
                  user?.role == 'admin' ? 'Yönetici (Admin)' : 'Sanatsever (Kullanıcı)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                backgroundColor: user?.role == 'admin' ? Colors.deepOrange : const Color(0xFF8D6E63),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Oturumu Kapat'),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Başarıyla çıkış yapıldı.')),
                    );
                    onLogout();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
