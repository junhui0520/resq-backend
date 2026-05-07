import '../core/api_client.dart';

// ── 모델 ──────────────────────────────────────────────────────

class UserSettings {
  final bool alertEnabled;
  final bool soundEnabled;
  final bool locationEnabled;
  final String selectedRegionCode;
  final String languageCode;

  const UserSettings({
    required this.alertEnabled,
    required this.soundEnabled,
    required this.locationEnabled,
    required this.selectedRegionCode,
    required this.languageCode,
  });

  factory UserSettings.fromJson(Map<String, dynamic> j) => UserSettings(
        alertEnabled:        j['alert_enabled']         ?? true,
        soundEnabled:        j['sound_enabled']         ?? true,
        locationEnabled:     j['location_enabled']      ?? true,
        selectedRegionCode:  j['selected_region_code']  ?? 'CHEONAN',
        languageCode:        j['language_code']         ?? 'en',
      );

  Map<String, dynamic> toJson() => {
        'alert_enabled':        alertEnabled,
        'sound_enabled':        soundEnabled,
        'location_enabled':     locationEnabled,
        'selected_region_code': selectedRegionCode,
        'language_code':        languageCode,
      };

  UserSettings copyWith({
    bool? alertEnabled,
    bool? soundEnabled,
    bool? locationEnabled,
    String? selectedRegionCode,
    String? languageCode,
  }) =>
      UserSettings(
        alertEnabled:       alertEnabled       ?? this.alertEnabled,
        soundEnabled:       soundEnabled       ?? this.soundEnabled,
        locationEnabled:    locationEnabled    ?? this.locationEnabled,
        selectedRegionCode: selectedRegionCode ?? this.selectedRegionCode,
        languageCode:       languageCode       ?? this.languageCode,
      );
}

class RegionModel {
  final String code;
  final String nameEn;
  final String nameKo;

  const RegionModel({
    required this.code,
    required this.nameEn,
    required this.nameKo,
  });

  factory RegionModel.fromJson(Map<String, dynamic> j) => RegionModel(
        code:   j['code']    ?? '',
        nameEn: j['name_en'] ?? '',
        nameKo: j['name_ko'] ?? '',
      );
}

// ── 서비스 ────────────────────────────────────────────────────

class UserService {
  /// 설정 조회
  static Future<UserSettings> fetchSettings(int userId) async {
    final res = await ApiClient.get('/users/$userId/settings');
    return UserSettings.fromJson(res);
  }

  /// 설정 수정
  static Future<bool> updateSettings(int userId, UserSettings settings) async {
    final res = await ApiClient.put(
      '/users/$userId/settings',
      settings.toJson(),
    );
    return res['updated'] == true;
  }

  /// 지역 목록 조회
  static Future<List<RegionModel>> fetchRegions() async {
    final res = await ApiClient.get('/regions');
    final list = res['regions'] as List<dynamic>? ?? [];
    return list.map((e) => RegionModel.fromJson(e)).toList();
  }
}
