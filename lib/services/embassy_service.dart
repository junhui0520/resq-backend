import '../core/api_client.dart';

// ── 모델 ──────────────────────────────────────────────────────

class EmbassyModel {
  final int id;
  final String countryCode;
  final String nameEn;
  final String addressEn;
  final String phone;
  final double? latitude;
  final double? longitude;

  const EmbassyModel({
    required this.id,
    required this.countryCode,
    required this.nameEn,
    required this.addressEn,
    required this.phone,
    this.latitude,
    this.longitude,
  });

  factory EmbassyModel.fromJson(Map<String, dynamic> j) => EmbassyModel(
        id:          j['id']         ?? 0,
        countryCode: j['country_code'] ?? '',
        nameEn:      j['name_en']    ?? '',
        addressEn:   j['address_en'] ?? '',
        phone:       j['phone']      ?? '',
        latitude:    (j['latitude']  as num?)?.toDouble(),
        longitude:   (j['longitude'] as num?)?.toDouble(),
      );
}

class EmergencyNumber {
  final String label;
  final String number;
  final String descriptionEn;

  const EmergencyNumber({
    required this.label,
    required this.number,
    required this.descriptionEn,
  });

  factory EmergencyNumber.fromJson(Map<String, dynamic> j) => EmergencyNumber(
        label:         j['label']          ?? '',
        number:        j['number']         ?? '',
        descriptionEn: j['description_en'] ?? '',
      );
}

// ── 서비스 ────────────────────────────────────────────────────

class EmbassyService {
  /// 대사관 목록 조회
  static Future<List<EmbassyModel>> fetchEmbassies({String? country}) async {
    final params = <String, String>{};
    if (country != null && country.isNotEmpty) params['country'] = country;

    final res = await ApiClient.get('/embassies', queryParams: params);
    final list = res['embassies'] as List<dynamic>? ?? [];
    return list.map((e) => EmbassyModel.fromJson(e)).toList();
  }

  /// 긴급전화 목록 조회
  static Future<List<EmergencyNumber>> fetchEmergencyNumbers() async {
    final res = await ApiClient.get('/emergency-numbers');
    final list = res['numbers'] as List<dynamic>? ?? [];
    return list.map((e) => EmergencyNumber.fromJson(e)).toList();
  }
}
