class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String walletAddress;
  final int totalSpots;
  final int totalReviews;
  final int totalCheckIns;
  final int reputation;
  final List<String> badges;
  final bool isTrustedReviewer;
  final bool isValidator;
  final DateTime createdAt;
  final DateTime? lastCheckIn;
  final int checkInStreak;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.walletAddress,
    this.totalSpots = 0,
    this.totalReviews = 0,
    this.totalCheckIns = 0,
    this.reputation = 0,
    this.badges = const [],
    this.isTrustedReviewer = false,
    this.isValidator = false,
    required this.createdAt,
    this.lastCheckIn,
    this.checkInStreak = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      walletAddress: json['wallet_address'] as String,
      totalSpots: json['total_spots'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalCheckIns: json['total_check_ins'] as int? ?? 0,
      reputation: json['reputation'] as int? ?? 0,
      badges: json['badges'] != null 
          ? List<String>.from(json['badges'] as List)
          : [],
      isTrustedReviewer: json['is_trusted_reviewer'] as bool? ?? false,
      isValidator: json['is_validator'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastCheckIn: json['last_check_in'] != null
          ? DateTime.parse(json['last_check_in'] as String)
          : null,
      checkInStreak: json['check_in_streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'wallet_address': walletAddress,
      'total_spots': totalSpots,
      'total_reviews': totalReviews,
      'total_check_ins': totalCheckIns,
      'reputation': reputation,
      'badges': badges,
      'is_trusted_reviewer': isTrustedReviewer,
      'is_validator': isValidator,
      'created_at': createdAt.toIso8601String(),
      'last_check_in': lastCheckIn?.toIso8601String(),
      'check_in_streak': checkInStreak,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? walletAddress,
    int? totalSpots,
    int? totalReviews,
    int? totalCheckIns,
    int? reputation,
    List<String>? badges,
    bool? isTrustedReviewer,
    bool? isValidator,
    DateTime? createdAt,
    DateTime? lastCheckIn,
    int? checkInStreak,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      walletAddress: walletAddress ?? this.walletAddress,
      totalSpots: totalSpots ?? this.totalSpots,
      totalReviews: totalReviews ?? this.totalReviews,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      reputation: reputation ?? this.reputation,
      badges: badges ?? this.badges,
      isTrustedReviewer: isTrustedReviewer ?? this.isTrustedReviewer,
      isValidator: isValidator ?? this.isValidator,
      createdAt: createdAt ?? this.createdAt,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      checkInStreak: checkInStreak ?? this.checkInStreak,
    );
  }
}