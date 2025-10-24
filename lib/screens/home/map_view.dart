import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/location_provider.dart';
import '../../models/location_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/search_text_field.dart';
import '../../widgets/common/loading_overlay.dart';
import '../location/add_location_screen.dart';
import '../location/location_detail_screen.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool _showLocationList = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.getCurrentPosition();
    await locationProvider.loadNearbyLocations();
    
    // Center map on user location
    if (locationProvider.currentPosition != null) {
      _mapController.move(
        LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        ),
        AppConstants.defaultZoom,
      );
    }
  }

  void _onMarkerTapped(LocationModel location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationDetailScreen(location: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          return LoadingOverlay(
            isLoading: locationProvider.isLoading,
            child: Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: locationProvider.currentPosition != null
                        ? LatLng(
                            locationProvider.currentPosition!.latitude,
                            locationProvider.currentPosition!.longitude,
                          )
                        : const LatLng(7.3775, 3.9470), // Ibadan default
                    initialZoom: AppConstants.defaultZoom,
                    minZoom: AppConstants.minZoom,
                    maxZoom: AppConstants.maxZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.spotbase.app',
                    ),
                    CurrentLocationLayer(),
                    MarkerLayer(
                      markers: locationProvider.nearbyLocations.map((location) {
                        return Marker(
                          point: LatLng(location.latitude, location.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _onMarkerTapped(location),
                            child: Container(
                              decoration: BoxDecoration(
                                color: location.isVerified
                                    ? AppTheme.primaryColor
                                    : Colors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Helpers.getCategoryIcon(location.category),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                              .animate()
                              .scale(delay: 200.ms, duration: 300.ms, curve: Curves.elasticOut),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Top bar with search
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          SearchTextField(
                            controller: _searchController,
                            hint: 'Search locations...',
                            onChanged: (value) {
                              // Implement search
                            },
                          ),
                          const SizedBox(height: 12),
                          // Category filter
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildCategoryChip('All', null),
                                ...LocationCategory.all.map(
                                  (category) => _buildCategoryChip(category, category),
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
                      .slideY(begin: -0.5, end: 0),
                ),

                // Bottom sheet toggle
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'list',
                        onPressed: () {
                          setState(() {
                            _showLocationList = !_showLocationList;
                          });
                        },
                        backgroundColor: Colors.white,
                        child: Icon(
                          _showLocationList ? Icons.map : Icons.list,
                          color: AppTheme.primaryColor,
                        ),
                      )
                          .animate()
                          .scale(delay: 400.ms, duration: 300.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: 'center',
                        onPressed: () {
                          if (locationProvider.currentPosition != null) {
                            _mapController.move(
                              LatLng(
                                locationProvider.currentPosition!.latitude,
                                locationProvider.currentPosition!.longitude,
                              ),
                              AppConstants.defaultZoom,
                            );
                          }
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.my_location,
                          color: AppTheme.primaryColor,
                        ),
                      )
                          .animate()
                          .scale(delay: 500.ms, duration: 300.ms, curve: Curves.elasticOut),
                    ],
                  ),
                ),

                // Location list bottom sheet
                if (_showLocationList)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Nearby Locations',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: locationProvider.nearbyLocations.length,
                              itemBuilder: (context, index) {
                                final location = locationProvider.nearbyLocations[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Helpers.getCategoryColor(location.category)
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Helpers.getCategoryIcon(location.category),
                                      color: Helpers.getCategoryColor(location.category),
                                    ),
                                  ),
                                  title: Text(location.name),
                                  subtitle: Text(location.category),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _onMarkerTapped(location),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .slideY(begin: 1, end: 0, duration: 300.ms),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLocationScreen()),
          );
        },
        icon: const Icon(Icons.add_location),
        label: const Text('Spot Location'),
        backgroundColor: AppTheme.primaryColor,
      )
          .animate()
          .scale(delay: 600.ms, duration: 300.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          // Reload locations with filter
          context.read<LocationProvider>().loadLocations(category: _selectedCategory);
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}