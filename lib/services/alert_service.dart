import '../core/api_client.dart';

// ── 모델 ──────────────────────────────────────────────────────

class AlertModel {
  final int id;
  final String regionCode;
  final String regionName;
  final String categoryCode;
  final String categoryLabel;
  final String colorHex;
  final String severityCode;
  final String severityLabel;
  final String title;
  final String content;
  final String actionGuide;
  final String status;
  final String issuedAt;

  const AlertModel({
    required this.id,
    required this.regionCode,
    required this.regionName,
    required this.categoryCode,
    required this.categoryLabel,
    required this.colorHex,
    required this.severityCode,
    required this.severityLabel,
    required this.title,
    required this.content,
    required this.actionGuide,
    required this.status,
    required this.issuedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
        id:            j['id'],
        regionCode:    j['region_code']    ?? '',
        regionName:    j['region_name']    ?? '',
        categoryCode:  j['category_code']  ?? '',
        categoryLabel: j['category_label'] ?? '',
        colorHex:      j['color_hex']      ?? '#9AA5B4',
        severityCode:  j['severity_code']  ?? '',
        severityLabel: j['severity_label'] ?? '',
        title:         j['title']          ?? '',
        content:       j['content']        ?? '',
        actionGuide:   j['action_guide']   ?? '',
        status:        j['status']         ?? '',
        issuedAt:      j['issued_at']      ?? '',
      );

  bool get isActive => status == 'ACTIVE';
}

class AlertCategory {
  final String code;
  final String labelEn;
  final String colorHex;

  const AlertCategory({
    required this.code,
    required this.labelEn,
    required this.colorHex,
  });

  factory AlertCategory.fromJson(Map<String, dynamic> j) => AlertCategory(
        code:     j['code']     ?? '',
        labelEn:  j['label_en'] ?? '',
        colorHex: j['color_hex'] ?? '#9AA5B4',
      );
}

// ── 서비스 ────────────────────────────────────────────────────

class AlertService {
  /// 알림 목록 조회
  static Future<List<AlertModel>> fetchAlerts({
    String? regionCode,
    String? categoryCode,
    String? status,
    String lang = 'en',
  }) async {
    final params = <String, String>{'lang': lang};
    if (regionCode   != null) params['region_code']   = regionCode;
    if (categoryCode != null) params['category_code'] = categoryCode;
    if (status       != null) params['status']        = status;

    final res = await ApiClient.get('/alerts', queryParams: params);
    final list = res['alerts'] as List<dynamic>? ?? [];
    return list.map((e) => AlertModel.fromJson(e)).toList();
  }

  /// 알림 상세 조회
  static Future<AlertModel> fetchAlertDetail(int id, {String lang = 'en'}) async {
    final res = await ApiClient.get('/alerts/$id', queryParams: {'lang': lang});
    return AlertModel.fromJson(res);
  }

  /// 카테고리 목록 조회
  static Future<List<AlertCategory>> fetchCategories() async {
    final res = await ApiClient.get('/alerts/categories');
    final list = res['categories'] as List<dynamic>? ?? [];
    return list.map((e) => AlertCategory.fromJson(e)).toList();
  }
}
