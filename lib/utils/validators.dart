class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Confirm password validator
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Required field validator
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }

    return null;
  }

  // Location name validator
  static String? validateLocationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location name is required';
    }

    if (value.length < 3) {
      return 'Location name must be at least 3 characters';
    }

    if (value.length > 100) {
      return 'Location name must not exceed 100 characters';
    }

    return null;
  }

  // Description validator
  static String? validateDescription(String? value, {int minLength = 10, int maxLength = 500}) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.length < minLength) {
      return 'Description must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return 'Description must not exceed $maxLength characters';
    }

    return null;
  }

  // Review comment validator
  static String? validateReviewComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Review comment is required';
    }

    if (value.length < 10) {
      return 'Review must be at least 10 characters';
    }

    if (value.length > 1000) {
      return 'Review must not exceed 1000 characters';
    }

    return null;
  }

  // Rating validator
  static String? validateRating(int? value) {
    if (value == null) {
      return 'Please select a rating';
    }

    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }

    return null;
  }

  // Coordinate validator
  static String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Latitude is required';
    }

    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Invalid latitude format';
    }

    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }

    return null;
  }

  static String? validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Longitude is required';
    }

    final lon = double.tryParse(value);
    if (lon == null) {
      return 'Invalid longitude format';
    }

    if (lon < -180 || lon > 180) {
      return 'Longitude must be between -180 and 180';
    }

    return null;
  }

  // Phone number validator (optional)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  // URL validator (optional)
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w\-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }

    return null;
  }

  // Wallet address validator
  static String? validateWalletAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wallet address is required';
    }

    final ethAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!ethAddressRegex.hasMatch(value)) {
      return 'Invalid Ethereum wallet address';
    }

    return null;
  }

  // Number validator
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }

    if (min != null && number < min) {
      return 'Value must be at least $min';
    }

    if (max != null && number > max) {
      return 'Value must not exceed $max';
    }

    return null;
  }

  // Category validator
  static String? validateCategory(String? value, List<String> validCategories) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }

    if (!validCategories.contains(value)) {
      return 'Invalid category selected';
    }

    return null;
  }
}