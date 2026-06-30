/// Normalizes and validates cooperative short names (e.g. SSF, BRAC).
class CoopShortName {
  static final _validPattern = RegExp(r'^[A-Z0-9]{2,12}$');

  static String normalize(String input) =>
      input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static String? validationError(String input) {
    final n = normalize(input);
    if (n.length < 2) return 'too_short';
    if (n.length > 12) return 'too_long';
    if (!_validPattern.hasMatch(n)) return 'invalid';
    return null;
  }
}
