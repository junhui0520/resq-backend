import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // 번역된 텍스트로 새 AlertModel 생성
  AlertModel copyWith({
    String? title,
    String? content,
    String? actionGuide,
  }) => AlertModel(
        id: id,
        regionCode: regionCode,
        regionName: regionName,
        categoryCode: categoryCode,
        categoryLabel: categoryLabel,
        colorHex: colorHex,
        severityCode: severityCode,
        severityLabel: severityLabel,
        title: title ?? this.title,
        content: content ?? this.content,
        actionGuide: actionGuide ?? this.actionGuide,
        status: status,
        issuedAt: issuedAt,
      );
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
        code:     j['code']      ?? '',
        labelEn:  j['label_en']  ?? '',
        colorHex: j['color_hex'] ?? '#9AA5B4',
      );
}

// ── 번역 캐시 ─────────────────────────────────────────────────
// {langCode: {alertId: AlertModel}}
final Map<String, Map<int, AlertModel>> _translateCache = {};

// ── 서비스 ────────────────────────────────────────────────────
class AlertService {

  /// Google Translate 비공식 API로 단일 텍스트 번역
  static Future<String> _translateText(String text, String targetLang) async {
    if (text.isEmpty || targetLang == 'en') return text;
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=en&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // 응답 구조: [[["번역된텍스트","원본",...],...],...]
        final buffer = StringBuffer();
        for (final item in data[0]) {
          if (item[0] != null) buffer.write(item[0]);
        }
        return buffer.toString();
      }
    } catch (_) {}
    return text; // 실패 시 원본 반환
  }

  /// 알림 목록 조회 + 필요 시 번역
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
    final alerts = list.map((e) => AlertModel.fromJson(e)).toList();

    // 영어면 번역 불필요
    if (lang == 'en') return alerts;

    // 캐시 확인
    final cached = _translateCache[lang];

    final List<AlertModel> translated = [];
    for (final alert in alerts) {
      // 캐시에 있으면 바로 사용
      if (cached != null && cached.containsKey(alert.id)) {
        translated.add(cached[alert.id]!);
        continue;
      }

      // 캐시 없으면 번역 API 호출
      try {
        final tTitle = await _translateText(alert.title, lang);
        final tContent = await _translateText(alert.content, lang);
        final tAction = await _translateText(alert.actionGuide, lang);

        final translatedAlert = alert.copyWith(
          title: tTitle,
          content: tContent,
          actionGuide: tAction,
        );

        // 캐시 저장
        _translateCache[lang] ??= {};
        _translateCache[lang]![alert.id] = translatedAlert;
        translated.add(translatedAlert);
      } catch (_) {
        // 번역 실패 시 원본 사용
        translated.add(alert);
      }
    }

    return translated;
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
