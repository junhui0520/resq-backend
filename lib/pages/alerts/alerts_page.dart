import 'package:flutter/material.dart';

const Color kNavy = Color(0xFF1B2F6E);

// ── 데이터 모델 ──────────────────────────────────────────────
class AlertItem {
  final String title;
  final String timeLabel;
  final String tagLabel;
  final Color tagColor;
  final Color tagTextColor;
  final String description;
  final Color borderColor;
  final String category; // 'all' | 'rain' | 'earthquake' | ...

  const AlertItem({
    required this.title,
    required this.timeLabel,
    required this.tagLabel,
    required this.tagColor,
    required this.tagTextColor,
    required this.description,
    required this.borderColor,
    required this.category,
  });
}

final List<AlertItem> _allAlerts = [
  AlertItem(
    title: 'Heavy Rain Warning\n· Cheonan',
    timeLabel: '09:38',
    tagLabel: 'High',
    tagColor: const Color(0xFFFFD6D6),
    tagTextColor: const Color(0xFFD04040),
    description: 'Avoid low-lying areas',
    borderColor: const Color(0xFFE57373),
    category: 'rain',
  ),
  AlertItem(
    title: 'Flood watch\n· Chungnam',
    timeLabel: '09:12',
    tagLabel: 'Med',
    tagColor: const Color(0xFFFFEDD5),
    tagTextColor: const Color(0xFFD07820),
    description: 'Statewide advisory',
    borderColor: const Color(0xFFFFB74D),
    category: 'rain',
  ),
  AlertItem(
    title: 'Poor air quality\n· Seoul',
    timeLabel: '08:00',
    tagLabel: 'Air',
    tagColor: const Color(0xFFEDE0FF),
    tagTextColor: const Color(0xFF7B4FBF),
    description: 'PM2.5 very high',
    borderColor: const Color(0xFFB39DDB),
    category: 'all',
  ),
  AlertItem(
    title: 'Strong wind\nadvisory · Jeju',
    timeLabel: 'Yesterday',
    tagLabel: 'Wind',
    tagColor: const Color(0xFFDDEEFF),
    tagTextColor: const Color(0xFF3A78C0),
    description: 'Gusts up to 70 km/h',
    borderColor: const Color(0xFF90CAF9),
    category: 'all',
  ),
  AlertItem(
    title: 'Earthquake M3.2\n· Gyeongbuk',
    timeLabel: '2 days ago',
    tagLabel: 'Quake',
    tagColor: const Color(0xFFFFE0B2),
    tagTextColor: const Color(0xFFE65100),
    description: 'Low risk',
    borderColor: const Color(0xFFFFB74D),
    category: 'earthquake',
  ),
  AlertItem(
    title: 'Forest fire\n· Gangwon',
    timeLabel: '3 days ago',
    tagLabel: 'Fire',
    tagColor: const Color(0xFFD6F5DC),
    tagTextColor: const Color(0xFF2E7D32),
    description: 'Resolved',
    borderColor: const Color(0xFF81C784),
    category: 'all',
  ),
];

// ── 필터 탭 정의 ─────────────────────────────────────────────
class _FilterTab {
  final String label;
  final String key;
  final Color activeColor;
  final Color textColor;

  const _FilterTab({
    required this.label,
    required this.key,
    required this.activeColor,
    required this.textColor,
  });
}

const List<_FilterTab> _filters = [
  _FilterTab(label: 'All', key: 'all', activeColor: kNavy, textColor: Colors.white),
  _FilterTab(label: 'Rain', key: 'rain', activeColor: Color(0xFFFFD6D6), textColor: Color(0xFFD04040)),
  _FilterTab(label: 'Earthquake', key: 'earthquake', activeColor: Color(0xFFFFEDD5), textColor: Color(0xFFD07820)),
];

// ── 메인 페이지 ───────────────────────────────────────────────
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _selectedFilter = 'all';

  List<AlertItem> get _filtered {
    if (_selectedFilter == 'all') return _allAlerts;
    return _allAlerts
        .where((a) => a.category == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 필터 칩 행
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? f.activeColor
                            : const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? f.textColor
                              : const Color(0xFF718096),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 알림 목록
          Expanded(
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _AlertCard(item: _filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 알림 카드 ─────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final AlertItem item;
  const _AlertCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: item.borderColor, width: 4),
        ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kNavy,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.timeLabel,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.tagColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.tagLabel,
                    style: TextStyle(
                      color: item.tagTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13,
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
