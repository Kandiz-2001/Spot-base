import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/web3_service.dart';
import '../services/wallet_service.dart';

class LocationProvider with ChangeNotifier {
  final _supabase = SupabaseService.instance;
  final _storage = StorageService.instance;
  final _locationService = LocationService.instance;
  final _web3 = Web3Service.instance;
  final _wallet = WalletService.instance;

  List<LocationModel> _locations = [];
  List<LocationModel> _nearbyLocations = [];
  LocationModel? _selectedLocation;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  List<LocationModel> get locations => _locations;
  List<LocationModel> get nearbyLocations => _nearbyLocations;
  LocationModel? get selectedLocation => _selectedLocation;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all locations
  Future<void> loadLocations({String? category}) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await _supabase.getLocations(
        limit: 100,
        category: category,
        isVerified: true,
      );

      _locations = data.map((json) => LocationModel.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Load nearby locations
  Future<void> loadNearbyLocations() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      
      final data = await _supabase.getNearbyLocations(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusInMeters: 5000,
      );

      _nearbyLocations = data.map((json) => LocationModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading nearby locations: $e');
    }
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Add location
  Future<bool> addLocation({
    required String name,
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required String addedBy,
    required String addedByWallet,
    List<File>? images,
    bool useGps = true,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Check GPS proximity if manual entry
      if (!useGps && _currentPosition != null) {
        final isWithinRadius = _locationService.isLocationWithinRadius(
          latitude,
          longitude,
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        if (!isWithinRadius) {
          _error = 'Location is too far from your current position';
          _setLoading(false);
          notifyListeners();
          return false;
        }
      }

      // Upload images
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _storage.uploadLocationImages(images);
      }

      // Get address
      final address = await _locationService.getAddressFromCoordinates(
        latitude,
        longitude,
      );

      // Create location in Supabase
      final locationData = {
        'name': name,
        'category': category,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'image_urls': imageUrls,
        'added_by': addedBy,
        'added_by_wallet': addedByWallet,
        'is_verified': useGps,
        'is_pending': !useGps,
        'created_at': DateTime.now().toIso8601String(),
      };

      final locationId = await _supabase.createLocation(locationData);

      // If verified, add to blockchain
      if (useGps && _wallet.isConnected) {
        try {
          // Add to blockchain would require credentials
          // This is simplified - actual implementation needs proper transaction signing
          print('Location added to Supabase with ID: $locationId');
        } catch (e) {
          print('Blockchain transaction failed: $e');
        }
      }

      await loadLocations();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Load location by ID
  Future<void> loadLocation(String locationId) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await _supabase.getLocation(locationId);
      if (data != null) {
        _selectedLocation = LocationModel.fromJson(data);
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Verify location (for validators)
  Future<bool> verifyLocation(String locationId, String verifiedBy) async {
    _setLoading(true);
    _error = null;

    try {
      await _supabase.updateLocation(locationId, {
        'is_verified': true,
        'is_pending': false,
        'verified_at': DateTime.now().toIso8601String(),
        'verified_by': verifiedBy,
      });

      await loadLocations();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

    /// Calculates the distance between two points in meters using the Haversine formula.
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    // Convert degrees to radians
    double latRad1 = math.pi * lat1 / 180;
    double latRad2 = math.pi * lat2 / 180;
    double deltaLatRad = math.pi * (lat2 - lat1) / 180;
    double deltaLonRad = math.pi * (lon2 - lon1) / 180;

    // Haversine formula
    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(latRad1) *
            math.cos(latRad2) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distance = earthRadius * c; // Output distance in meters
    return distance;
  }

  // Search locations
  List<LocationModel> searchLocations(String query) {
    if (query.isEmpty) return _locations;

    final lowerQuery = query.toLowerCase();
    return _locations.where((location) {
      return location.name.toLowerCase().contains(lowerQuery) ||
             location.category.toLowerCase().contains(lowerQuery) ||
             location.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter by category
  List<LocationModel> filterByCategory(String category) {
    return _locations.where((location) => location.category == category).toList();
  }

  void setSelectedLocation(LocationModel? location) {
    _selectedLocation = location;
    notifyListeners();
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