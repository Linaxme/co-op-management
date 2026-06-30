/// Maps member phone numbers to Firebase Auth email addresses per cooperative.

class MemberAuthEmail {

  static const domain = 'members.ssf.local';



  static String fromPhone(String phoneNormalized, String coopId) =>

      '${coopId}_$phoneNormalized@$domain';



  /// Pre–multi-tenant format (no coop prefix).

  static String legacyFromPhone(String phoneNormalized) =>

      '$phoneNormalized@$domain';



  static String? phoneFromEmail(String? email) {

    if (email == null || !email.endsWith('@$domain')) return null;

    final local = email.split('@').first;

    final underscore = local.indexOf('_');

    if (underscore < 0) return local;

    return local.substring(underscore + 1);

  }



  static String? coopIdFromEmail(String? email) {

    if (email == null || !email.endsWith('@$domain')) return null;

    final local = email.split('@').first;

    final underscore = local.indexOf('_');

    if (underscore < 0) return null;

    return local.substring(0, underscore);

  }



  static bool isLegacyEmail(String? email) {

    if (email == null || !email.endsWith('@$domain')) return false;

    return !email.split('@').first.contains('_');

  }

}

