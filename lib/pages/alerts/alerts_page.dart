import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/alert_service.dart';

const Color kNavy = Color(0xFF1B2F6E);

// ── 카테고리 정의 (고정) ──────────────────────────────────────
class _Category {
  final String code;
  final String labelKey;  // app_strings 키
  final Color color;

  const _Category({
    required this.code,
    required this.labelKey,
    required this.color,
  });
}

const List<_Category> kCategories = [
  _Category(code: 'ALL',        labelKey: 'filter_all',        color: kNavy),
  _Category(code: 'RAIN',       labelKey: 'filter_rain',       color: Color(0xFF1565C0)),
  _Category(code: 'FLOOD',      labelKey: 'filter_flood',      color: Color(0xFF0277BD)),
  _Category(code: 'EARTHQUAKE', labelKey: 'filter_earthquake', color: Color(0xFFBF360C)),
  _Category(code: 'FIRE',       labelKey: 'filter_fire',       color: Color(0xFFE53935)),
  _Category(code: 'SNOW',       labelKey: 'filter_snow',       color: Color(0xFF5C6BC0)),
  _Category(code: 'LANDSLIDE',  labelKey: 'filter_landslide',  color: Color(0xFF6D4C41)),
  _Category(code: 'OTHER',      labelKey: 'filter_other',      color: Color(0xFF546E7A)),
];

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<AlertModel> _alerts = [];
  String _selectedCategory = 'ALL';
  bool   _isLoading = true;
  String? _error;
  String _lastLang = '';

  @override
void initState() {
  super.initState();
  setState(() => _isLoading = true); // ← 추가
  _loadAll();
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = context.read<LanguageProvider>().currentLang;
    if (_lastLang != currentLang && _lastLang.isNotEmpty) {
      _lastLang = currentLang;
      _loadAll();
    } else {
      _lastLang = currentLang;
    }
  }

  Future<void> _loadAll() async {
  setState(() { _error = null; }); // ← _isLoading = true 제거
  try {
    final lang = context.read<LanguageProvider>().currentLang;
    final alerts = await AlertService.fetchAlerts(lang: lang);
    setState(() {
      _alerts = alerts;
      _isLoading = false;
    });
  } catch (e) {
    setState(() { _error = e.toString(); _isLoading = false; });
  }
}

  List<AlertModel> get _filtered {
    if (_selectedCategory == 'ALL') return _alerts;
    return _alerts.where((a) => a.categoryCode == _selectedCategory).toList();
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
        title: Text(
          lang.t('nav_alerts'),
          style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── 필터 칩 ───────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kCategories.map((cat) {
                  final isSelected = _selectedCategory == cat.code;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: lang.t(cat.labelKey),
                      selected: isSelected,
                      activeColor: cat.code == 'ALL'
                          ? kNavy
                          : cat.color.withValues(alpha: 0.15),
                      activeTextColor: cat.code == 'ALL'
                          ? Colors.white
                          : cat.color,
                      onTap: () => setState(() => _selectedCategory = cat.code),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── 본문 ─────────────────────────────────────────
          Expanded(child: _buildBody(lang)),
        ],
      ),
    );
  }

  Widget _buildBody(LanguageProvider lang) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: kNavy),
            const SizedBox(height: 14),
            Text(
              lang.t('alerts_loading'),
              style: const TextStyle(color: Color(0xFF9AA5B4)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, color: Color(0xFFCBD5E0), size: 48),
            const SizedBox(height: 12),
            Text(
              lang.t('alerts_connection_error'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9AA5B4), fontSize: 13, height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(lang.t('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, color: Color(0xFFCBD5E0), size: 48),
            const SizedBox(height: 12),
            Text(
              lang.t('alerts_empty'),
              style: const TextStyle(color: Color(0xFF9AA5B4)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kNavy,
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _AlertCard(
          item: _filtered[index],
          lang: lang,
        ),
      ),
    );
  }
}

// ── 필터 칩 ───────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? activeTextColor : const Color(0xFF718096),
          ),
        ),
      ),
    );
  }
}

// ── 알림 카드 ─────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final AlertModel item;
  final LanguageProvider lang;
  const _AlertCard({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    final borderColor = _hexColor(item.colorHex);
    final isActive = item.status == 'ACTIVE';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                    item.title,
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: kNavy, height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(item.issuedAt),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9AA5B4)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // 심각도/카테고리 태그
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.severityLabel.isNotEmpty
                        ? item.severityLabel
                        : item.categoryLabel,
                    style: TextStyle(
                      color: borderColor, fontSize: 11, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Active / Resolved 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFFEEEE)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive
                        ? lang.t('alert_active')
                        : lang.t('alert_resolved'),
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFFB12B2B)
                          : const Color(0xFF2E7D32),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.actionGuide.isNotEmpty
                        ? item.actionGuide
                        : item.content,
                    style: const TextStyle(
                      fontSize: 13, color: Color(0xFF718096),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String issuedAt) {
    try {
      final dt = DateTime.parse(issuedAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) {
      return issuedAt;
    }
  }

  static Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF9AA5B4);
    }
  }
}
