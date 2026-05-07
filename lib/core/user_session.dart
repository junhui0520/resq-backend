import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'api_client.dart';

/// 앱 최초 실행 시 device_uuid 생성 + 서버 유저 등록
class UserSession {
  static const _uuidKey   = 'device_uuid';
  static const _userIdKey = 'user_id';

  static String? _deviceUuid;
  static int?    _userId;

  static String? get deviceUuid => _deviceUuid;
  static int?    get userId     => _userId;

  /// 앱 시작 시 한 번만 호출
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // device_uuid 없으면 새로 생성
    _deviceUuid = prefs.getString(_uuidKey);
    if (_deviceUuid == null) {
      _deviceUuid = const Uuid().v4();
      await prefs.setString(_uuidKey, _deviceUuid!);
    }

    // 저장된 userId 불러오기
    _userId = prefs.getInt(_userIdKey);

    // 서버에 등록 (이미 등록됐으면 기존 userId 반환)
    try {
      final res = await ApiClient.post('/users', {
        'device_uuid':    _deviceUuid,
        'nationality':    'Unknown',
        'language_code':  'en',
      });
      _userId = res['user_id'] as int?;
      if (_userId != null) {
        await prefs.setInt(_userIdKey, _userId!);
      }
    } catch (_) {
      // 서버 연결 실패해도 앱 실행은 계속
    }
  }
}
