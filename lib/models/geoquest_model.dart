class GeoQuestModel {
  final String id;
  final String title;
  final String description;
  final String questType;
  final int targetCount;
  final String? targetCategory;
  final double? targetLatitude;
  final double? targetLongitude;
  final double? radiusInMeters;
  final String rewardAmount;
  final String badgeName;
  final String? badgeImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int completedBy;

  GeoQuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questType,
    required this.targetCount,
    this.targetCategory,
    this.targetLatitude,
    this.targetLongitude,
    this.radiusInMeters,
    required this.rewardAmount,
    required this.badgeName,
    this.badgeImageUrl,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.completedBy = 0,
  });

  factory GeoQuestModel.fromJson(Map<String, dynamic> json) {
    return GeoQuestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questType: json['quest_type'] as String,
      targetCount: json['target_count'] as int,
      targetCategory: json['target_category'] as String?,
      targetLatitude: (json['target_latitude'] as num?)?.toDouble(),
      targetLongitude: (json['target_longitude'] as num?)?.toDouble(),
      radiusInMeters: (json['radius_in_meters'] as num?)?.toDouble(),
      rewardAmount: json['reward_amount'] as String,
      badgeName: json['badge_name'] as String,
      badgeImageUrl: json['badge_image_url'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      completedBy: json['completed_by'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quest_type': questType,
      'target_count': targetCount,
      'target_category': targetCategory,
      'target_latitude': targetLatitude,
      'target_longitude': targetLongitude,
      'radius_in_meters': radiusInMeters,
      'reward_amount': rewardAmount,
      'badge_name': badgeName,
      'badge_image_url': badgeImageUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'completed_by': completedBy,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get isAvailable => hasStarted && !isExpired && isActive;

  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }
}

class UserQuestModel {
  final String id;
  final String userId;
  final String questId;
  final int progress;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? badgeNftUri;

  UserQuestModel({
    required this.id,
    required this.userId,
    required this.questId,
    this.progress = 0,
    this.isCompleted = false,
    this.completedAt,
    this.badgeNftUri,
  });

  factory UserQuestModel.fromJson(Map<String, dynamic> json) {
    return UserQuestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      questId: json['quest_id'] as String,
      progress: json['progress'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      badgeNftUri: json['badge_nft_uri'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quest_id': questId,
      'progress': progress,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'badge_nft_uri': badgeNftUri,
    };
  }

  double getProgressPercentage(int targetCount) {
    if (targetCount == 0) return 0.0;
    return (progress / targetCount * 100).clamp(0.0, 100.0);
  }
}

// Quest Types
class QuestType {
  static const String spotLocations = 'spot_locations';
  static const String addReviews = 'add_reviews';
  static const String checkIn = 'check_in';
  static const String verifyLocations = 'verify_locations';
  static const String exploreCategory = 'explore_category';
  static const String exploreArea = 'explore_area';

  static List<String> get all => [
    spotLocations,
    addReviews,
    checkIn,
    verifyLocations,
    exploreCategory,
    exploreArea,
  ];
}