class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    if (value.length < 5) {
      return 'Email must be at least 5 characters long';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nickname cannot be empty';
    }
    if (value.length < 3) {
      return 'Nickname must be at least 3 characters long';
    }
    if (value.length > 16) {
      return 'Nickname cannot exceed 16 characters';
    }
    return null;
  }
}
