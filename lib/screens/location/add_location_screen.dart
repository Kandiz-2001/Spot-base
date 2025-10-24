import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/location_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedCategory;
  bool _useGps = true;
  double? _latitude;
  double? _longitude;
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (_useGps) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();
    final position = await locationProvider.getCurrentPosition();
    
    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      Helpers.showSnackBar(context, 'Please select a category', isError: true);
      return;
    }

    if (_latitude == null || _longitude == null) {
      Helpers.showSnackBar(context, 'Location not available', isError: true);
      return;
    }

    if (_images.isEmpty) {
      final confirm = await Helpers.showConfirmDialog(
        context,
        title: 'No Images',
        message: 'Are you sure you want to add location without images?',
      );
      if (!confirm) return;
    }

    final authProvider = context.read<AuthProvider>();
    final locationProvider = context.read<LocationProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user == null) return;

    Helpers.showLoadingDialog(context, message: 'Adding location...');

    final success = await locationProvider.addLocation(
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      addedBy: authProvider.user!.id,
      addedByWallet: authProvider.user!.walletAddress,
      images: _images.isNotEmpty ? _images : null,
      useGps: _useGps,
    );

    Helpers.hideLoadingDialog(context);

    if (!mounted) return;

    if (success) {
      await userProvider.incrementSpots();
      await userProvider.incrementReputation(10);
      
      Helpers.showSnackBar(context, 'Location added successfully!');
      Navigator.of(context).pop();
    } else {
      Helpers.showSnackBar(
        context,
        locationProvider.error ?? 'Failed to add location',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spot Location'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location method toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _useGps ? Icons.gps_fixed : Icons.edit_location,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _useGps ? 'Using GPS Location' : 'Manual Entry',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _useGps
                                ? 'Your current location will be used'
                                : 'Enter location manually',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useGps,
                      onChanged: (value) {
                        setState(() {
                          _useGps = value;
                          if (value) {
                            _getCurrentLocation();
                          }
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Location name
              CustomTextField(
                controller: _nameController,
                label: 'Location Name',
                hint: 'e.g., Cocoa Mall',
                prefixIcon: Icons.place,
                validator: Validators.validateLocationName,
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 16),

              // Category dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        _selectedCategory != null
                            ? Helpers.getCategoryIcon(_selectedCategory!)
                            : Icons.category,
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                    ),
                    items: LocationCategory.all.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              Helpers.getCategoryIcon(category),
                              size: 20,
                              color: Helpers.getCategoryColor(category),
                            ),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell us about this place...',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) => Validators.validateDescription(
                  value,
                  minLength: 10,
                  maxLength: 500,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),

              if (!_useGps) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter location address',
                  prefixIcon: Icons.location_on,
                  validator: (value) =>
                      Validators.validateRequired(value, fieldName: 'Address'),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
              ],

              const SizedBox(height: 24),

              // Images
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photos (Optional)',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_images.isEmpty)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 150,
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
                              size: 48,
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
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _images.length) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 120,
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
                                width: 120,
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
                                      size: 16,
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
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // Submit button
              GradientButton(
                text: 'Add Location',
                onPressed: _submit,
                icon: Icons.add_location,
                width: double.infinity,
                height: 56,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}