class LocationModel {
  final String id;
  final int? blockchainId;
  final String name;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> imageUrls;
  final String? ipfsHash;
  final String addedBy;
  final String addedByWallet;
  final bool isVerified;
  final bool isPending;
  final int reviewCount;
  final double averageRating;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  LocationModel({
    required this.id,
    this.blockchainId,
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrls = const [],
    this.ipfsHash,
    required this.addedBy,
    required this.addedByWallet,
    this.isVerified = false,
    this.isPending = false,
    this.reviewCount = 0,
    this.averageRating = 0.0,
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      blockchainId: json['blockchain_id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : [],
      ipfsHash: json['ipfs_hash'] as String?,
      addedBy: json['added_by'] as String,
      addedByWallet: json['added_by_wallet'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      isPending: json['is_pending'] as bool? ?? false,
      reviewCount: json['review_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      verifiedBy: json['verified_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blockchain_id': blockchainId,
      'name': name,
      'category': category,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'image_urls': imageUrls,
      'ipfs_hash': ipfsHash,
      'added_by': addedBy,
      'added_by_wallet': addedByWallet,
      'is_verified': isVerified,
      'is_pending': isPending,
      'review_count': reviewCount,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
    };
  }

  LocationModel copyWith({
    String? id,
    int? blockchainId,
    String? name,
    String? category,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? imageUrls,
    String? ipfsHash,
    String? addedBy,
    String? addedByWallet,
    bool? isVerified,
    bool? isPending,
    int? reviewCount,
    double? averageRating,
    DateTime? createdAt,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) {
    return LocationModel(
      id: id ?? this.id,
      blockchainId: blockchainId ?? this.blockchainId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      imageUrls: imageUrls ?? this.imageUrls,
      ipfsHash: ipfsHash ?? this.ipfsHash,
      addedBy: addedBy ?? this.addedBy,
      addedByWallet: addedByWallet ?? this.addedByWallet,
      isVerified: isVerified ?? this.isVerified,
      isPending: isPending ?? this.isPending,
      reviewCount: reviewCount ?? this.reviewCount,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }
}

// Location Categories
class LocationCategory {
  static const String restaurant = 'Restaurant';
  static const String cafe = 'Cafe';
  static const String park = 'Park';
  static const String museum = 'Museum';
  static const String hotel = 'Hotel';
  static const String shop = 'Shop';
  static const String landmark = 'Landmark';
  static const String entertainment = 'Entertainment';
  static const String other = 'Other';

  static List<String> get all => [
    restaurant,
    cafe,
    park,
    museum,
    hotel,
    shop,
    landmark,
    entertainment,
    other,
  ];
}