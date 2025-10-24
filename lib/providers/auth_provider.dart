import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../services/wallet_service.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = SupabaseService.instance;
  final _walletService = WalletService.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _supabase.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _loadUser();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });

    // Check if already logged in
    if (_supabase.currentUser != null) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return;

      final userData = await _supabase.getUser(userId);
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _supabase.signUpWithEmail(email, password);

      if (response.user != null) {
        final walletAddress = await _walletService.connect();

        final userData = {
          'id': response.user!.id,
          'email': email,
          'wallet_address': walletAddress,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.createUser(userData);
        // _loadUser will be called by the authStateChanges listener automatically
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _supabase.signInWithEmail(email, password);

      if (response.user != null) {
        // _loadUser will be called by the authStateChanges listener automatically
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      // Step 1: Initiate the OAuth flow
      // The bool return value indicates if the flow *started* successfully
      bool flowStarted = await _supabase.signInWithGoogle();

      if (!flowStarted) {
        // The OAuth flow couldn't even be initiated (e.g., browser couldn't open)
        _error = "Failed to start Google sign-in process.";
        _setLoading(false);
        return false;
      }

      // Step 2: Wait for the auth state change (success or failure handled by listener)
      // Rely on _user being set by the listener/_loadUser after the flow completes
      await Future.delayed(const Duration(milliseconds: 500)); // Small delay

      // Check the outcome based on the provider's state after the flow attempt
      bool success = _user != null;
      _setLoading(false); // Stop loading regardless of outcome
      return success;

    } catch (e) {
      // This handles errors *during* the call to _supabase.signInWithGoogle()
      _error = e.toString();
      _setLoading(false);
      print('Error starting Google sign-in: $e');
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    _setLoading(true);
    _error = null;

    try {
      // Step 1: Initiate the OAuth flow
      bool flowStarted = await _supabase.signInWithApple();

      if (!flowStarted) {
        // The OAuth flow couldn't even be initiated (e.g., browser couldn't open)
        _error = "Failed to start Apple sign-in process.";
        _setLoading(false);
        return false;
      }

      // Step 2: Wait for the auth state change (success or failure handled by listener)
      await Future.delayed(const Duration(milliseconds: 500)); // Small delay

      // Check the outcome based on the provider's state after the flow attempt
      bool success = _user != null;
      _setLoading(false); // Stop loading regardless of outcome
      return success;

    } catch (e) {
      // This handles errors *during* the call to _supabase.signInWithApple()
      _error = e.toString();
      _setLoading(false);
      print('Error starting Apple sign-in: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _walletService.disconnect();
      await _supabase.signOut();
      // The authStateChanges listener will handle resetting _user
      _setLoading(false);
      // notifyListeners(); // The listener will call notifyListeners() when _user changes
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_user == null) return;

    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      if (updates.isNotEmpty) {
        await _supabase.updateUser(_user!.id, updates);
        await _loadUser(); // Reload user data after update
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
