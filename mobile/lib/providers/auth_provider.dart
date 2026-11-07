import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    AuthService? authService,
    StorageService? storageService,
  })  : _authService = authService ?? AuthService(),
        _storageService = storageService ?? StorageService();

  // 3. Hafta: Global State Getters (isLoggedIn, userRole, currentUser)
  bool get isLoggedIn => _token != null && _currentUser != null;
  String? get userRole => _currentUser?.role;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == 'admin';

  // 3. Hafta: Otomatik Oturum Açma Kontrolü (Uygulama başladığında)
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await _storageService.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _token = savedToken;
      _currentUser = await _authService.getCurrentUser(savedToken);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      // Token geçersiz veya sunucuya erişilemiyor
      await _storageService.deleteToken();
      _token = null;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Hafta: Kullanıcı Giriş İşlemi
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final receivedToken = await _authService.login(
        email: email,
        password: password,
      );

      _token = receivedToken;
      await _storageService.saveToken(receivedToken);

      // Kullanıcı profilini çek
      _currentUser = await _authService.getCurrentUser(receivedToken);

      // Opsiyonel: kullanıcı profilini de güvenli hafızada sakla
      await _storageService.saveUserData(json.encode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Giriş yapılırken beklenmeyen bir hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Hafta: Kullanıcı Kayıt İşlemi
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Kayıt işlemi sırasında bir hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Hafta: Oturum Kapatma (Logout)
  Future<void> logout() async {
    await _storageService.deleteToken();
    _token = null;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
