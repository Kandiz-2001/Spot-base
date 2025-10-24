import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/location_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/review/review_card.dart';

class AddReviewScreen extends StatefulWidget {
  final LocationModel location;

  const AddReviewScreen({
    super.key,
    required this.location,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _rating = 0;
  final List<File> _images = [];
  bool _verifiedVisit = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.length > 5) {
        Helpers.showSnackBar(
          context,
          'Maximum 5 images allowed',
          isError: true,
        );
        return;
      }

      setState(() {
        _images.clear();
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to pick images', isError: true);
    }
  }

  Future<void> _checkIfUserAtLocation() async {
    final locationService = context.read<LocationProvider>();
    
    try {
      final position = await locationService.getCurrentPosition();
      if (position != null) {
        final distance = locationService.calculateDistance(
          position.latitude,
          position.longitude,
          widget.location.latitude,
          widget.location.longitude,
        );

        if (distance <= 100) {
          setState(() {
            _verifiedVisit = true;
          });
          Helpers.showSnackBar(
            context,
            'Location verified! You\'ll earn bonus rewards.',
          );
        }
      }
    } catch (e) {
      print('Error checking location: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      Helpers.showSnackBar(
        context,
        'Please select a rating',
        isError: true,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final reviewProvider = context.read<ReviewProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user == null) return;

    Helpers.showLoadingDialog(context, message: 'Submitting review...');

    final success = await reviewProvider.addReview(
      locationId: widget.location.id,
      locationBlockchainId: widget.location.blockchainId,
      userId: authProvider.user!.id,
      userWallet: authProvider.user!.walletAddress,
      userName: authProvider.user!.displayName ?? 'Anonymous',
      userPhotoUrl: authProvider.user!.photoUrl,
      rating: _rating,
      comment: _commentController.text.trim(),
      images: _images.isNotEmpty ? _images : null,
      verifiedVisit: _verifiedVisit,
      isTrustedReviewer: authProvider.user!.isTrustedReviewer,
    );

    Helpers.hideLoadingDialog(context);

    if (!mounted) return;

    if (success) {
      await userProvider.incrementReviews();
      await userProvider.incrementReputation(5);

      Helpers.showSnackBar(context, 'Review submitted successfully!');
      Navigator.of(context).pop();
    } else {
      Helpers.showSnackBar(
        context,
        reviewProvider.error ?? 'Failed to submit review',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Helpers.getCategoryColor(widget.location.category)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Helpers.getCategoryIcon(widget.location.category),
                        color: Helpers.getCategoryColor(widget.location.category),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.location.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.location.category,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Rating',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: RatingBar(
                      rating: _rating,
                      onRatingChanged: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                      size: 40,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Comment
              CustomTextField(
                controller: _commentController,
                label: 'Your Review',
                hint: 'Share your experience...',
                maxLines: 5,
                maxLength: 1000,
                validator: Validators.validateReviewComment,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // Photos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Photos (Optional)',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_images.isEmpty)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add Photos',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _images.length) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _images.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Verify location
              GestureDetector(
                onTap: _checkIfUserAtLocation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _verifiedVisit
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _verifiedVisit
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _verifiedVisit
                            ? Icons.check_circle
                            : Icons.location_searching,
                        color: _verifiedVisit
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _verifiedVisit
                                  ? 'Location Verified'
                                  : 'Verify Your Visit',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _verifiedVisit
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              _verifiedVisit
                                  ? 'Earn bonus rewards for verified visit'
                                  : 'Tap to verify you\'re at this location',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // Submit button
              GradientButton(
                text: 'Submit Review',
                onPressed: _submit,
                icon: Icons.send,
                width: double.infinity,
                height: 56,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}