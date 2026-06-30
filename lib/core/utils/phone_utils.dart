/// Phone normalization for member login (Bangladesh + international).
class PhoneUtils {
  /// Normalize to `01XXXXXXXXX` (11 digits) or null if not a BD mobile.
  static String? normalize(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('880')) {
      digits = digits.substring(3);
    }
    if (digits.length == 10 && digits.startsWith('1')) {
      digits = '0$digits';
    }
    if (digits.length == 11 && digits.startsWith('01')) {
      return digits;
    }
    return null;
  }

  /// Login id: BD `01XXXXXXXXX`, or international digits with country code (10–15).
  static String? normalizeForLogin(String? phone) {
    final bd = normalize(phone);
    if (bd != null) return bd;

    if (phone == null || phone.trim().isEmpty) return null;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10 && digits.length <= 15) {
      return digits;
    }
    return null;
  }

  static String? resolveMemberLoginPhone(String? phone, String? phoneNormalized) {
    final fromRaw = normalizeForLogin(phone);
    if (fromRaw != null) return fromRaw;
    return normalizeForLogin(phoneNormalized);
  }

  static bool isValid(String? phone) => normalize(phone) != null;

  static bool isValidForLogin(String? phone) => normalizeForLogin(phone) != null;

  static String validationMessage(String locale) {
    return locale == 'bn'
        ? 'সঠিক মোবাইল নম্বর দিন (বাংলাদেশ: 01XXXXXXXXX, বিদেশ: দেশকোডসহ)'
        : 'Enter a valid mobile number (BD: 01XXXXXXXXX, abroad: with country code)';
  }
}
