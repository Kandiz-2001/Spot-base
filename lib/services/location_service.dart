import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../config/constants.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  LocationService._();

  // Check location permission
  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Request location permission
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied &&
           permission != LocationPermission.deniedForever;
  }

  // Get current position
  Future<Position> getCurrentPosition() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts = [
          placemark.street,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((part) => part != null && part.isNotEmpty);
        
        return parts.join(', ');
      }
      
      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown location';
    }
  }

  // Get coordinates from address
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  // Calculate distance between two points (in meters)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Check if manual location is within acceptable radius
  bool isLocationWithinRadius(
    double manualLat,
    double manualLon,
    double currentLat,
    double currentLon,
  ) {
    final distance = calculateDistance(
      manualLat,
      manualLon,
      currentLat,
      currentLon,
    );
    return distance <= AppConstants.spotVerificationRadius;
  }

  // Get location stream
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  // Check if user is at location for check-in
  Future<bool> isUserAtLocation(
    double locationLat,
    double locationLon,
    {double radiusInMeters = 100.0}
  ) async {
    try {
      final position = await getCurrentPosition();
      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        locationLat,
        locationLon,
      );
      return distance <= radiusInMeters;
    } catch (e) {
      return false;
    }
  }
}