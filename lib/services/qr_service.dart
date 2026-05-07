import '../core/api_client.dart';
import '../core/user_session.dart';

// ── 모델 ──────────────────────────────────────────────────────

class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
        name:         j['name']         ?? '',
        relationship: j['relationship'] ?? '',
        phone:        j['phone']        ?? '',
      );
}

class MedicalInfo {
  final String category; // 'allergy' | 'condition'
  final String value;

  const MedicalInfo({required this.category, required this.value});

  factory MedicalInfo.fromJson(Map<String, dynamic> j) => MedicalInfo(
        category: j['category'] ?? '',
        value:    j['value']    ?? '',
      );
}

class QrProfile {
  final String name;
  final String gender;
  final int age;
  final String bloodType;
  final String nationality;
  final List<EmergencyContact> emergencyContacts;
  final List<MedicalInfo> medicalInfos;

  const QrProfile({
    required this.name,
    required this.gender,
    required this.age,
    required this.bloodType,
    required this.nationality,
    required this.emergencyContacts,
    required this.medicalInfos,
  });

  factory QrProfile.fromJson(Map<String, dynamic> j) => QrProfile(
        name:        j['name']       ?? '',
        gender:      j['gender']     ?? '',
        age:         j['age']        ?? 0,
        bloodType:   j['blood_type'] ?? '',
        nationality: j['nationality'] ?? '',
        emergencyContacts: (j['emergency_contacts'] as List<dynamic>? ?? [])
            .map((e) => EmergencyContact.fromJson(e))
            .toList(),
        medicalInfos: (j['medical_infos'] as List<dynamic>? ?? [])
            .map((e) => MedicalInfo.fromJson(e))
            .toList(),
      );

  List<MedicalInfo> get allergies =>
      medicalInfos.where((m) => m.category == 'allergy').toList();

  List<MedicalInfo> get conditions =>
      medicalInfos.where((m) => m.category == 'condition').toList();
}

// ── 서비스 ────────────────────────────────────────────────────

class QrService {
  /// QR 스캔 결과 조회
  static Future<QrProfile> fetchQrProfile(String qrToken) async {
    final res = await ApiClient.get('/qr/$qrToken');
    return QrProfile.fromJson(res);
  }

  /// QR 프로필 등록/수정
  static Future<String> saveQrProfile({
    required String name,
    required String gender,
    required int age,
    required String bloodType,
    required String nationality,
  }) async {
    final userId = UserSession.userId;
    if (userId == null) throw Exception('로그인 정보가 없습니다.');

    final res = await ApiClient.post('/users/$userId/qr-profile', {
      'name':        name,
      'gender':      gender,
      'age':         age,
      'blood_type':  bloodType,
      'nationality': nationality,
    });

    return res['qr_url'] as String? ?? '';
  }
}
