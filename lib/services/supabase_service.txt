import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // Auth Methods
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Corrected return type: Future<bool> - matches the underlying SDK
  Future<bool> signInWithGoogle() async {
    // Returns true if the OAuth flow was initiated successfully, false otherwise.
    return await client.auth.signInWithOAuth(OAuthProvider.google);
  }

  // Corrected return type: Future<bool> - matches the underlying SDK
  Future<bool> signInWithApple() async {
    // Returns true if the OAuth flow was initiated successfully, false otherwise.
    return await client.auth.signInWithOAuth(OAuthProvider.apple);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // User Methods
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final response = await client
        .from(AppConstants.usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    await client.from(AppConstants.usersTable).insert(userData);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await client
        .from(AppConstants.usersTable)
        .update(updates)
        .eq('id', userId);
  }

  // Location Methods
  Future<List<Map<String, dynamic>>> getLocations({
    int? limit,
    String? category,
    bool? isVerified,
  }) async {
    // --- CORRECTED QUERY CHAINING ---
    var filterQuery = client
        .from(AppConstants.locationsTable)
        .select();

    if (category != null) {
      filterQuery = filterQuery.eq('category', category); // Apply filter
    }
    if (isVerified != null) {
      filterQuery = filterQuery.eq('is_verified', isVerified); // Apply filter
    }

    // Chain order and limit after filters
    var finalQuery = filterQuery.order('created_at', ascending: false);
    if (limit != null) {
      finalQuery = finalQuery.limit(limit);
    }

    final response = await finalQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radiusInMeters = 5000,
  }) async {
    final response = await client.rpc('nearby_locations', params: {
      'lat': latitude,
      'long': longitude,
      'radius': radiusInMeters,
    });
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getLocation(String locationId) async {
    final response = await client
        .from(AppConstants.locationsTable)
        .select()
        .eq('id', locationId)
        .maybeSingle();
    return response;
  }

  Future<String> createLocation(Map<String, dynamic> locationData) async {
    final response = await client
        .from(AppConstants.locationsTable)
        .insert(locationData)
        .select()
        .single();
    return response['id'] as String;
  }

  Future<void> updateLocation(String locationId, Map<String, dynamic> updates) async {
    await client
        .from(AppConstants.locationsTable)
        .update(updates)
        .eq('id', locationId);
  }

  // Review Methods
  Future<List<Map<String, dynamic>>> getReviewsForLocation(String locationId) async {
    final response = await client
        .from(AppConstants.reviewsTable)
        .select()
        .eq('location_id', locationId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<String> createReview(Map<String, dynamic> reviewData) async {
    final response = await client
        .from(AppConstants.reviewsTable)
        .insert(reviewData)
        .select()
        .single();
    return response['id'] as String;
  }

  // Check-in Methods
  Future<bool> canCheckIn(String userId, String locationId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final response = await client
        .from(AppConstants.checkInsTable)
        .select()
        .eq('user_id', userId)
        .eq('location_id', locationId)
        .gte('created_at', startOfDay.toIso8601String())
        .maybeSingle();
    return response == null;
  }

  Future<void> createCheckIn(Map<String, dynamic> checkInData) async {
    await client.from(AppConstants.checkInsTable).insert(checkInData);
  }

  Future<int> getUserCheckInStreak(String userId) async {
    final response = await client.rpc('get_user_check_in_streak', params: {
      'user_uuid': userId,
    });
    return response as int? ?? 0;
  }

  // GeoQuest Methods
  Future<List<Map<String, dynamic>>> getActiveGeoQuests() async {
    final now = DateTime.now().toIso8601String();
    final response = await client
        .from(AppConstants.geoQuestsTable)
        .select()
        .eq('is_active', true)
        .lte('start_date', now)
        .gte('end_date', now)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getUserQuest(String userId, String questId) async {
    final response = await client
        .from(AppConstants.userQuestsTable)
        .select()
        .eq('user_id', userId)
        .eq('quest_id', questId)
        .maybeSingle();
    return response;
  }

  Future<void> updateUserQuestProgress(
    String userId,
    String questId,
    int progress,
  ) async {
    final existing = await getUserQuest(userId, questId);
    if (existing == null) {
      await client.from(AppConstants.userQuestsTable).insert({
        'user_id': userId,
        'quest_id': questId,
        'progress': progress,
      });
    } else {
      await client
          .from(AppConstants.userQuestsTable)
          .update({'progress': progress})
          .eq('user_id', userId)
          .eq('quest_id', questId);
    }
  }

  // Leaderboard Methods
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String sortBy = 'reputation',
    int limit = 50,
  }) async {
    final response = await client
        .from(AppConstants.usersTable)
        .select()
        .order(sortBy, ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }
}
