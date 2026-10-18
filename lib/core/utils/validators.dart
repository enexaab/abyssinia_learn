class Validators {
  Validators._();

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your full name';
    if (text.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email';
    final pattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please enter your password';
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
