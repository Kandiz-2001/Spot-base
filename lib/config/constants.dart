import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Blockchain
  static String get rpcUrl => dotenv.env['RPC_URL'] ?? 'https://sepolia.base.org';
  static int get chainId => int.parse(dotenv.env['CHAIN_ID'] ?? '84532');
  static String get networkName => dotenv.env['NETWORK_NAME'] ?? 'Base Sepolia';
  
  // Contract Addresses
  static String get tokenAddress => dotenv.env['SPOTBASE_TOKEN_ADDRESS'] ?? '';
  static String get registryAddress => dotenv.env['LOCATION_REGISTRY_ADDRESS'] ?? '';
  static String get reviewNftAddress => dotenv.env['REVIEW_NFT_ADDRESS'] ?? '';
  
  // WalletConnect
  static String get walletConnectProjectId => dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';
  
  // App Config
  static const String appName = 'SpotBase';
  static const int maxReviewsPerLocation = 5;
  static const double spotVerificationRadius = 200.0; // meters
  static const int dailyCheckInLimit = 1;
  
  // Reward Values (in SBT tokens with 18 decimals)
  static const String spotReward = '10';
  static const String reviewReward = '5';
  static const String checkInReward = '2';
  static const String verificationReward = '15';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Map Configuration
  static const double defaultZoom = 15.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;
  
  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImagesPerReview = 5;
  
  // Supabase Tables
  static const String usersTable = 'users';
  static const String locationsTable = 'locations';
  static const String reviewsTable = 'reviews';
  static const String checkInsTable = 'check_ins';
  static const String geoQuestsTable = 'geo_quests';
  static const String userQuestsTable = 'user_quests';
  
  // Storage Buckets
  static const String locationImagesBucket = 'location-images';
  static const String reviewImagesBucket = 'review-images';
  static const String profileImagesBucket = 'profile-images';
}

class ErrorMessages {
  static const String noInternet = 'No internet connection';
  static const String locationPermissionDenied = 'Location permission denied';
  static const String walletConnectionFailed = 'Failed to connect wallet';
  static const String transactionFailed = 'Transaction failed';
  static const String imageUploadFailed = 'Failed to upload image';
  static const String invalidLocation = 'Invalid location';
  static const String tooFarFromGps = 'Location is too far from your GPS position';
  static const String dailyLimitReached = 'Daily limit reached';
  static const String maxReviewsReached = 'Maximum reviews reached for this location';
}

class SuccessMessages {
  static const String locationAdded = 'Location added successfully!';
  static const String reviewAdded = 'Review added successfully!';
  static const String checkInSuccess = 'Check-in successful!';
  static const String walletConnected = 'Wallet connected successfully!';
  static const String rewardsClaimed = 'Rewards claimed successfully!';
}