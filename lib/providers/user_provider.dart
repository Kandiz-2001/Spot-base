import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/geoquest_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../services/web3_service.dart';

class UserProvider with ChangeNotifier {
  final _supabase = SupabaseService.instance;
  final _storage = StorageService.instance;
  final _web3 = Web3Service.instance;

  UserModel? _currentUser;
  BigInt _tokenBalance = BigInt.zero;
  List<GeoQuestModel> _activeQuests = [];
  final List<UserQuestModel> _userQuests = [];
  List<UserModel> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  BigInt get tokenBalance => _tokenBalance;
  List<GeoQuestModel> get activeQuests => _activeQuests;
  List<UserQuestModel> get userQuests => _userQuests;
  List<UserModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get formattedTokenBalance {
    final balance = _tokenBalance.toDouble() / 1e18;
    return balance.toStringAsFixed(2);
  }

  // Load current user
  Future<void> loadCurrentUser(String userId) async {
    try {
      final data = await _supabase.getUser(userId);
      if (data != null) {
        _currentUser = UserModel.fromJson(data);
        
        // Load token balance
        if (_currentUser?.walletAddress != null) {
          await loadTokenBalance(_currentUser!.walletAddress);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  // Load token balance
  Future<void> loadTokenBalance(String walletAddress) async {
    try {
      _tokenBalance = await _web3.getTokenBalance(walletAddress);
      notifyListeners();
    } catch (e) {
      print('Error loading token balance: $e');
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    File? profileImage,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final updates = <String, dynamic>{};

      if (displayName != null) {
        updates['display_name'] = displayName;
      }

      if (profileImage != null) {
        final photoUrl = await _storage.uploadProfileImage(
          profileImage,
          _currentUser!.id,
        );
        updates['photo_url'] = photoUrl;
      }

      if (updates.isNotEmpty) {
        await _supabase.updateUser(_currentUser!.id, updates);
        await loadCurrentUser(_currentUser!.id);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Check-in at location
  Future<bool> checkIn(String locationId, double latitude, double longitude) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _error = null;

    try {
      // Check if user can check-in
      final canCheckIn = await _supabase.canCheckIn(_currentUser!.id, locationId);
      
      if (!canCheckIn) {
        _error = 'You have already checked in here today';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      // Create check-in
      final checkInData = {
        'user_id': _currentUser!.id,
        'location_id': locationId,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.createCheckIn(checkInData);

      // Update user stats
      final newCheckIns = _currentUser!.totalCheckIns + 1;
      final streak = await _supabase.getUserCheckInStreak(_currentUser!.id);

      await _supabase.updateUser(_currentUser!.id, {
        'total_check_ins': newCheckIns,
        'check_in_streak': streak,
        'last_check_in': DateTime.now().toIso8601String(),
      });

      await loadCurrentUser(_currentUser!.id);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Load active GeoQuests
  Future<void> loadActiveQuests() async {
    try {
      final data = await _supabase.getActiveGeoQuests();
      _activeQuests = data.map((json) => GeoQuestModel.fromJson(json)).toList();
      
      // Load user progress for each quest
      if (_currentUser != null) {
        await loadUserQuests();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading quests: $e');
    }
  }

  // Load user quest progress
  Future<void> loadUserQuests() async {
    if (_currentUser == null) return;

    try {
      _userQuests.clear();
      
      for (final quest in _activeQuests) {
        final data = await _supabase.getUserQuest(_currentUser!.id, quest.id);
        if (data != null) {
          _userQuests.add(UserQuestModel.fromJson(data));
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading user quests: $e');
    }
  }

  // Update quest progress
  Future<void> updateQuestProgress(String questId, int progress) async {
    if (_currentUser == null) return;

    try {
      await _supabase.updateUserQuestProgress(
        _currentUser!.id,
        questId,
        progress,
      );
      await loadUserQuests();
    } catch (e) {
      print('Error updating quest progress: $e');
    }
  }

  // Load leaderboard
  Future<void> loadLeaderboard({String sortBy = 'reputation'}) async {
    _setLoading(true);

    try {
      final data = await _supabase.getLeaderboard(sortBy: sortBy, limit: 50);
      _leaderboard = data.map((json) => UserModel.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Get user rank
  int getUserRank() {
    if (_currentUser == null) return 0;
    
    final index = _leaderboard.indexWhere((u) => u.id == _currentUser!.id);
    return index + 1;
  }

  // Increment user stats
  Future<void> incrementSpots() async {
    if (_currentUser == null) return;
    
    await _supabase.updateUser(_currentUser!.id, {
      'total_spots': _currentUser!.totalSpots + 1,
    });
    await loadCurrentUser(_currentUser!.id);
  }

  Future<void> incrementReviews() async {
    if (_currentUser == null) return;
    
    await _supabase.updateUser(_currentUser!.id, {
      'total_reviews': _currentUser!.totalReviews + 1,
    });
    await loadCurrentUser(_currentUser!.id);
  }

  Future<void> incrementReputation(int points) async {
    if (_currentUser == null) return;
    
    await _supabase.updateUser(_currentUser!.id, {
      'reputation': _currentUser!.reputation + points,
    });
    await loadCurrentUser(_currentUser!.id);
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