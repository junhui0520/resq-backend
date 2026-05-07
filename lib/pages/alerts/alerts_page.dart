import 'package:flutter/material.dart';
import '../../services/alert_service.dart';

const Color kNavy = Color(0xFF1B2F6E);

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<AlertCategory> _categories = [];
  List<AlertModel>    _alerts     = [];
  String _selectedCategory = 'ALL';
  bool   _isLoading  = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final cats    = await AlertService.fetchCategories();
      final alerts  = await AlertService.fetchAlerts();
      setState(() {
        _categories = cats;
        _alerts     = alerts;
        _isLoading  = false;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        titleSpacing: 20,
        title: const Text('Alerts',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
                children: [
                  // All 탭
                  _FilterChip(
                    label: 'All',
                    selected: _selectedCategory == 'ALL',
                    activeColor: kNavy,
                    activeTextColor: Colors.white,
                    onTap: () => setState(() => _selectedCategory = 'ALL'),
                  ),
                  const SizedBox(width: 8),
                  // 서버에서 받은 카테고리들
                  ..._categories.map((cat) {
                    final color = _hexColor(cat.colorHex);
                    final selected = _selectedCategory == cat.code;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: cat.labelEn,
                        selected: selected,
                        activeColor: color.withValues(alpha: 0.15),
                        activeTextColor: color,
                        onTap: () => setState(() => _selectedCategory = cat.code),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── 본문 ─────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kNavy),
            SizedBox(height: 14),
            Text('알림을 불러오는 중...', style: TextStyle(color: Color(0xFF9AA5B4))),
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
            Text('서버에 연결할 수 없습니다.\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9AA5B4), fontSize: 13, height: 1.6)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.notifications_none, color: Color(0xFFCBD5E0), size: 48),
          SizedBox(height: 12),
          Text('알림이 없습니다.', style: TextStyle(color: Color(0xFF9AA5B4))),
        ]),
      );
    }

    return RefreshIndicator(
      color: kNavy,
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: _filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _AlertCard(item: _filtered[index]),
      ),
    );
  }

  static Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF9AA5B4);
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
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
  const _AlertCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final borderColor = _hexColor(item.colorHex);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
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
                  child: Text(item.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kNavy, height: 1.4)),
                ),
                const SizedBox(width: 8),
                Text(_formatTime(item.issuedAt),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9AA5B4))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(item.severityLabel.isNotEmpty ? item.severityLabel : item.categoryLabel,
                      style: TextStyle(color: borderColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.actionGuide.isNotEmpty ? item.actionGuide : item.content,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF718096)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
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
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
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
