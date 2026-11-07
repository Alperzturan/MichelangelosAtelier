import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/storage_service.dart';

// Mock StorageService
class FakeStorageService extends StorageService {
  String? storedToken;
  String? storedUser;

  @override
  Future<void> saveToken(String token) async {
    storedToken = token;
  }

  @override
  Future<String?> getToken() async => storedToken;

  @override
  Future<void> deleteToken() async {
    storedToken = null;
  }

  @override
  Future<void> saveUserData(String userDataJson) async {
    storedUser = userDataJson;
  }

  @override
  Future<String?> getUserData() async => storedUser;

  @override
  Future<void> clearAll() async {
    storedToken = null;
    storedUser = null;
  }
}

// Mock AuthService
class FakeAuthService extends AuthService {
  bool shouldFail = false;
  String errorMessage = 'Hatalı işlem';

  @override
  Future<String> login({required String email, required String password}) async {
    if (shouldFail) throw AuthException(errorMessage);
    return 'fake_jwt_token_12345';
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (shouldFail) throw AuthException(errorMessage);
    return UserModel(
      id: 1,
      fullName: fullName,
      email: email,
      role: 'user',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    if (token != 'fake_jwt_token_12345') {
      throw const AuthException('Geçersiz token');
    }
    return UserModel(
      id: 1,
      fullName: 'Test Orhan',
      email: 'orhan@atelier.com',
      role: 'user',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  group('AuthProvider Tests (3. Hafta Görevi)', () {
    late FakeStorageService fakeStorage;
    late FakeAuthService fakeAuth;
    late AuthProvider authProvider;

    setUp(() {
      fakeStorage = FakeStorageService();
      fakeAuth = FakeAuthService();
      authProvider = AuthProvider(
        authService: fakeAuth,
        storageService: fakeStorage,
      );
    });

    test('Başlangıçta kullanıcı oturumu kapalı olmalıdır', () {
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.token, isNull);
    });

    test('Başarılı giriş yapıldığında state güncellenmeli ve token saklanmalıdır', () async {
      final success = await authProvider.login(
        email: 'orhan@atelier.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.token, equals('fake_jwt_token_12345'));
      expect(authProvider.currentUser?.fullName, equals('Test Orhan'));
      expect(authProvider.userRole, equals('user'));
      expect(await fakeStorage.getToken(), equals('fake_jwt_token_12345'));
    });

    test('Hatalı girişte errorMessage atanmalı ve oturum açılmamalıdır', () async {
      fakeAuth.shouldFail = true;
      fakeAuth.errorMessage = 'Geçersiz e-posta veya şifre.';

      final success = await authProvider.login(
        email: 'wrong@atelier.com',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.errorMessage, equals('Geçersiz e-posta veya şifre.'));
      expect(await fakeStorage.getToken(), isNull);
    });

    test('Çıkış yapıldığında token silinmeli ve state sıfırlanmalıdır', () async {
      await authProvider.login(
        email: 'orhan@atelier.com',
        password: 'password123',
      );
      expect(authProvider.isLoggedIn, isTrue);

      await authProvider.logout();
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.token, isNull);
      expect(authProvider.currentUser, isNull);
      expect(await fakeStorage.getToken(), isNull);
    });

    test('tryAutoLogin kayıtlı token varsa oturumu otomatik açmalıdır', () async {
      await fakeStorage.saveToken('fake_jwt_token_12345');

      final autoLoginSuccess = await authProvider.tryAutoLogin();
      expect(autoLoginSuccess, isTrue);
      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.currentUser?.fullName, equals('Test Orhan'));
    });
  });
}
