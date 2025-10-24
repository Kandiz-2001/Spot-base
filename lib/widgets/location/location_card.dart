import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/location_model.dart';
import '../../config/theme.dart';
import '../../utils/helpers.dart';

class LocationCard extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onTap;

  const LocationCard({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: location.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: location.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 40),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Helpers.getCategoryIcon(location.category),
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Helpers.getCategoryColor(location.category)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Helpers.getCategoryIcon(location.category),
                              size: 14,
                              color: Helpers.getCategoryColor(location.category),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Helpers.getCategoryColor(location.category),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (location.isVerified)
                        const Icon(
                          Icons.verified,
                          size: 18,
                          color: AppTheme.successColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating and reviews
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${location.reviewCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class LocationListTile extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onTap;

  const LocationListTile({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: location.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: location.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Helpers.getCategoryIcon(location.category),
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Helpers.getCategoryIcon(location.category),
                      color: Colors.grey[400],
                    ),
                  ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                location.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (location.isVerified)
              const Icon(
                Icons.verified,
                size: 16,
                color: AppTheme.successColor,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.category,
              style: TextStyle(
                fontSize: 12,
                color: Helpers.getCategoryColor(location.category),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  '${location.averageRating.toStringAsFixed(1)} (${location.reviewCount})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}