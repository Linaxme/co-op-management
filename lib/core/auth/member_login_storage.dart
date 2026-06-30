import 'package:shared_preferences/shared_preferences.dart';

class MemberLoginStorage {
  static const _keyShortName = 'member_login_short_name';
  static const _keyCoopId = 'member_login_coop_id';
  static const _keyCoopName = 'member_login_coop_name';

  static Future<void> save({
    required String shortName,
    required String coopId,
    required String coopName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyShortName, shortName);
    await prefs.setString(_keyCoopId, coopId);
    await prefs.setString(_keyCoopName, coopName);
  }

  static Future<({
    String shortName,
    String coopId,
    String coopName,
  })?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final shortName = prefs.getString(_keyShortName);
    final coopId = prefs.getString(_keyCoopId);
    final coopName = prefs.getString(_keyCoopName);
    if (shortName == null || coopId == null || coopName == null) return null;
    return (shortName: shortName, coopId: coopId, coopName: coopName);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyShortName);
    await prefs.remove(_keyCoopId);
    await prefs.remove(_keyCoopName);
  }
}
