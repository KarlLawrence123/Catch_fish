import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LocalUser {
  final String email;
  final String fullName;

  LocalUser({required this.email, required this.fullName});

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
      };

  factory LocalUser.fromJson(Map<String, dynamic> json) => LocalUser(
        email: json['email'],
        fullName: json['fullName'],
      );
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  LocalUser? _currentUser;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Get current user
  LocalUser? get currentUser => _currentUser;

  // Hash password for secure storage
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Initialize and check if user is logged in
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final userJson = prefs.getString('currentUser');
      if (userJson != null) {
        _currentUser = LocalUser.fromJson(json.decode(userJson));
      }
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user already exists
    final existingUsers = prefs.getStringList('users') ?? [];
    for (final userStr in existingUsers) {
      final user = json.decode(userStr);
      if (user['email'] == email) {
        throw 'An account already exists for that email.';
      }
    }

    // Validate password
    if (password.length < 6) {
      throw 'The password must be at least 6 characters.';
    }

    // Create new user
    final hashedPassword = _hashPassword(password);
    final newUser = {
      'email': email,
      'password': hashedPassword,
      'fullName': fullName,
    };

    existingUsers.add(json.encode(newUser));
    await prefs.setStringList('users', existingUsers);

    // Auto login after signup
    _currentUser = LocalUser(email: email, fullName: fullName);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingUsers = prefs.getStringList('users') ?? [];

    final hashedPassword = _hashPassword(password);

    for (final userStr in existingUsers) {
      final user = json.decode(userStr);
      if (user['email'] == email) {
        if (user['password'] == hashedPassword) {
          // Login successful
          _currentUser = LocalUser(email: email, fullName: user['fullName']);
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString(
              'currentUser', json.encode(_currentUser!.toJson()));
          return;
        } else {
          throw 'Wrong password provided.';
        }
      }
    }

    throw 'No user found for that email.';
  }

  // Send password reset email (offline version - just shows message)
  Future<void> sendPasswordResetEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final existingUsers = prefs.getStringList('users') ?? [];

    for (final userStr in existingUsers) {
      final user = json.decode(userStr);
      if (user['email'] == email) {
        // In offline mode, we can't actually send email
        // Just confirm the email exists
        return;
      }
    }

    throw 'No user found for that email.';
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUser');
    _currentUser = null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
