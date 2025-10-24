import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/location_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/review/review_card.dart';
import '../review/add_review_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  final LocationModel location;

  const LocationDetailScreen({
    super.key,
    required this.location,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviewProvider = context.read<ReviewProvider>();
    await reviewProvider.loadReviewsForLocation(widget.location.id);
  }

  Future<void> _checkIn() async {
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user == null) return;

    Helpers.showLoadingDialog(context, message: 'Checking in...');

    final success = await userProvider.checkIn(
      widget.location.id,
      widget.location.latitude,
      widget.location.longitude,
    );

    Helpers.hideLoadingDialog(context);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Check-in successful! +2 SBT');
    } else {
      Helpers.showSnackBar(
        context,
        userProvider.error ?? 'Check-in failed',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.location.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.location.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Helpers.getCategoryIcon(widget.location.category),
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Helpers.getCategoryIcon(widget.location.category),
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Helpers.getCategoryColor(
                                      widget.location.category)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Helpers.getCategoryIcon(
                                      widget.location.category),
                                  size: 16,
                                  color: Helpers.getCategoryColor(
                                      widget.location.category),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.location.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Helpers.getCategoryColor(
                                        widget.location.category),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (widget.location.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: AppTheme.successColor,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        widget.location.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 8),

                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.location.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.location.reviewCount} reviews)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 16),

                      // Address
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.location.address,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 16),

                      // Description
                      if (widget.location.description.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.location.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 16),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Check-in',
                              onPressed: _checkIn,
                              icon: Icons.check_circle_outline,
                              type: ButtonType.outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Add Review',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddReviewScreen(
                                      location: widget.location,
                                    ),
                                  ),
                                ).then((_) => _loadReviews());
                              },
                              icon: Icons.rate_review,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 24),

                      // Reviews section
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Consumer<ReviewProvider>(
                            builder: (context, reviewProvider, _) {
                              if (reviewProvider.reviews.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return PopupMenuButton<String>(
                                child: const Row(
                                  children: [
                                    Text(
                                      'Sort',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                                onSelected: (value) {
                                  reviewProvider.sortReviews(value);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'newest',
                                    child: Text('Newest'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'oldest',
                                    child: Text('Oldest'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'highest',
                                    child: Text('Highest Rated'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'lowest',
                                    child: Text('Lowest Rated'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'most_helpful',
                                    child: Text('Most Helpful'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Reviews list
                Consumer<ReviewProvider>(
                  builder: (context, reviewProvider, _) {
                    if (reviewProvider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (reviewProvider.reviews.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reviews yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Be the first to review this location',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: reviewProvider.reviews
                          .map((review) => ReviewCard(
                                review: review,
                                onVote: (isUpvote) async {
                                  await reviewProvider.voteReview(
                                    review.id,
                                    isUpvote,
                                  );
                                },
                              ))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}