import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../core/user_session.dart';
import 'qr_result_screen.dart';
import '../../core/api_client.dart';


const Color kNavy = Color(0xFF1B2F6E);

// ── Alert 모델 ────────────────────────────────────────────────
class AlertModel {
  final int id;
  final String regionName;
  final String categoryLabel;
  final String colorHex;
  final String title;
  final String status;
  final String issuedAt;

  AlertModel({
    required this.id,
    required this.regionName,
    required this.categoryLabel,
    required this.colorHex,
    required this.title,
    required this.status,
    required this.issuedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? 0,
      regionName: json['region_name'] ?? '',
      categoryLabel: json['category_label'] ?? '',
      colorHex: json['color_hex'] ?? '#9AA5B4',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      issuedAt: json['issued_at'] ?? '',
    );
  }

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF9AA5B4);
    }
  }

  String get timeAgo {
    try {
      final dt = DateTime.parse(issuedAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }
}

// ── HomeScreen ────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _baseUrl = 'http://localhost:3000/api';

  List<AlertModel> _recentAlerts = [];
  bool _hasActiveAlert = false;
  AlertModel? _activeAlert;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      final lang = context.read<LanguageProvider>().currentLang;
      final uri = Uri.parse('$_baseUrl/alerts').replace(
        queryParameters: {
          'lang': lang,
          'device_uuid': UserSession.deviceUuid,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List raw = data['alerts'] ?? [];
        final all = raw.map((e) => AlertModel.fromJson(e)).toList();

        final active = all.where((a) => a.status == 'ACTIVE').toList();
        all.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));

        setState(() {
          _hasActiveAlert = active.isNotEmpty;
          _activeAlert = active.isNotEmpty ? active.first : null;
          _recentAlerts = all.take(5).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'ResQ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrResultScreen()),
              ),
              icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 18),
              label: const Text(
                'My Info',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAlerts,
        color: kNavy,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // 상태 카드
            _hasActiveAlert && _activeAlert != null
                ? _DangerCard(alert: _activeAlert!)
                : _SafeCard(lang: lang),

            const SizedBox(height: 24),

            // Quick Actions
            _SectionLabel(lang.t('quick_actions')),
            const SizedBox(height: 10),
            _EmergencyCallCard(lang: lang),
            const SizedBox(height: 10),
            _SafetyGuideCard(lang: lang),

            const SizedBox(height: 24),

            // Recent Alerts
            _SectionLabel(lang.t('recent_alerts')),
            const SizedBox(height: 10),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: kNavy),
                ),
              )
            else if (_recentAlerts.isEmpty)
              _EmptyAlerts(lang: lang)
            else
              ..._recentAlerts.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AlertCard(alert: alert),
                  )),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: kNavy,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Safe Card ─────────────────────────────────────────────────
class _SafeCard extends StatelessWidget {
  final LanguageProvider lang;
  const _SafeCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF4CAF50), size: 12),
              const SizedBox(width: 8),
              Text(
                lang.t('no_active_alerts'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lang.t('area_safe'),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD0EED1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lang.t('all_clear'),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Danger Card ───────────────────────────────────────────────
class _DangerCard extends StatelessWidget {
  final AlertModel alert;
  const _DangerCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE58E8E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFFC0392B), size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB12B2B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCFCF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active · ${alert.regionName}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB12B2B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Emergency Call Card ───────────────────────────────────────
class _EmergencyCallCard extends StatelessWidget {
  final LanguageProvider lang;
  const _EmergencyCallCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kNavy,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    '119',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('call_119'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lang.t('fire_ambulance'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Safety Guide Card ─────────────────────────────────────────
class _SafetyGuideCard extends StatelessWidget {
  final LanguageProvider lang;
  const _SafetyGuideCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu, color: kNavy, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('safety_guide'),
                      style: const TextStyle(
                        color: kNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lang.t('safety_guide_sub'),
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E0)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Alert Card (API 데이터) ────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: alert.color, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kNavy,
                      height: 1.4,
                    ),
                  ),
                ),
                Text(
                  alert.timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA5B4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: alert.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.categoryLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${alert.regionName} · ${alert.status == 'ACTIVE' ? 'Active' : 'Resolved'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Alerts ──────────────────────────────────────────────
class _EmptyAlerts extends StatelessWidget {
  final LanguageProvider lang;
  const _EmptyAlerts({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_none, color: Colors.grey[400], size: 40),
          const SizedBox(height: 8),
          Text(
            lang.t('no_recent_alerts'),
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
