class ReviewModel {
  final String id;
  final int? nftTokenId;
  final String locationId;
  final int? locationBlockchainId;
  final String userId;
  final String userWallet;
  final String userName;
  final String? userPhotoUrl;
  final int rating;
  final String comment;
  final List<String> imageUrls;
  final String? nftUri;
  final bool verifiedVisit;
  final int upvotes;
  final int downvotes;
  final String rewardAmount;
  final DateTime createdAt;
  final bool isTrustedReviewer;

  ReviewModel({
    required this.id,
    this.nftTokenId,
    required this.locationId,
    this.locationBlockchainId,
    required this.userId,
    required this.userWallet,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    this.nftUri,
    this.verifiedVisit = false,
    this.upvotes = 0,
    this.downvotes = 0,
    this.rewardAmount = '0',
    required this.createdAt,
    this.isTrustedReviewer = false,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      nftTokenId: json['nft_token_id'] as int?,
      locationId: json['location_id'] as String,
      locationBlockchainId: json['location_blockchain_id'] as int?,
      userId: json['user_id'] as String,
      userWallet: json['user_wallet'] as String,
      userName: json['user_name'] as String? ?? 'Anonymous',
      userPhotoUrl: json['user_photo_url'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : [],
      nftUri: json['nft_uri'] as String?,
      verifiedVisit: json['verified_visit'] as bool? ?? false,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      rewardAmount: json['reward_amount'] as String? ?? '0',
      createdAt: DateTime.parse(json['created_at'] as String),
      isTrustedReviewer: json['is_trusted_reviewer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nft_token_id': nftTokenId,
      'location_id': locationId,
      'location_blockchain_id': locationBlockchainId,
      'user_id': userId,
      'user_wallet': userWallet,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
      'nft_uri': nftUri,
      'verified_visit': verifiedVisit,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'reward_amount': rewardAmount,
      'created_at': createdAt.toIso8601String(),
      'is_trusted_reviewer': isTrustedReviewer,
    };
  }

  ReviewModel copyWith({
    String? id,
    int? nftTokenId,
    String? locationId,
    int? locationBlockchainId,
    String? userId,
    String? userWallet,
    String? userName,
    String? userPhotoUrl,
    int? rating,
    String? comment,
    List<String>? imageUrls,
    String? nftUri,
    bool? verifiedVisit,
    int? upvotes,
    int? downvotes,
    String? rewardAmount,
    DateTime? createdAt,
    bool? isTrustedReviewer,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      nftTokenId: nftTokenId ?? this.nftTokenId,
      locationId: locationId ?? this.locationId,
      locationBlockchainId: locationBlockchainId ?? this.locationBlockchainId,
      userId: userId ?? this.userId,
      userWallet: userWallet ?? this.userWallet,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      nftUri: nftUri ?? this.nftUri,
      verifiedVisit: verifiedVisit ?? this.verifiedVisit,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      createdAt: createdAt ?? this.createdAt,
      isTrustedReviewer: isTrustedReviewer ?? this.isTrustedReviewer,
    );
  }

  double get votingScore {
    final total = upvotes + downvotes;
    if (total == 0) return 0.0;
    return (upvotes / total) * 100;
  }
}