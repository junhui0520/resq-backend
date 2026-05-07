import 'package:flutter/material.dart';
import '../../services/embassy_service.dart';

const Color kNavy = Color(0xFF1B2F6E);

class EmbassyPage extends StatefulWidget {
  const EmbassyPage({super.key});

  @override
  State<EmbassyPage> createState() => _EmbassyPageState();
}

class _EmbassyPageState extends State<EmbassyPage> {
  final TextEditingController _searchController = TextEditingController();

  List<EmbassyModel> _embassies = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEmbassies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmbassies({String search = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await EmbassyService.fetchEmbassies(
        country: search.isNotEmpty ? search : null,
      );
      setState(() {
        _embassies = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 불러오지 못했습니다.\n$e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value) {
        _loadEmbassies(search: value);
      }
    });
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
          'Embassy',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ── 검색창 ──────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: const TextStyle(
                    color: Color(0xFFB0B8C8), fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFFB0B8C8), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Color(0xFFB0B8C8), size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF2F4F8),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── 본문 ────────────────────────────────────────
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
            Text('공관 정보를 불러오는 중...',
                style: TextStyle(color: Color(0xFF9AA5B4), fontSize: 14)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  color: Color(0xFFCBD5E0), size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF9AA5B4), fontSize: 13, height: 1.6)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _loadEmbassies(search: _searchQuery),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_embassies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: Color(0xFFCBD5E0), size: 48),
            SizedBox(height: 12),
            Text('검색 결과가 없습니다.',
                style: TextStyle(color: Color(0xFF9AA5B4), fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kNavy,
      onRefresh: () => _loadEmbassies(search: _searchQuery),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: _embassies.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) =>
            _EmbassyCard(data: _embassies[index]),
      ),
    );
  }
}

// ── 공관 카드 ─────────────────────────────────────────────────

class _EmbassyCard extends StatelessWidget {
  final EmbassyModel data;
  const _EmbassyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.nameEn,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kNavy),
                    ),
                    if (data.addressEn.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        data.addressEn,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF718096)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (data.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '📞 ${data.phone}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF718096)),
                      ),
                    ],
                  ],
                ),
              ),
              if (data.countryCode.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.countryCode,
                    style: const TextStyle(
                        fontSize: 11,
                        color: kNavy,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone,
                  label: 'Call now',
                  filled: true,
                  onTap: data.phone.isNotEmpty ? () {} : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.location_on_outlined,
                  label: 'Directions',
                  filled: false,
                  onTap: data.addressEn.isNotEmpty ? () {} : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: filled
          ? (disabled ? const Color(0xFFCBD5E0) : kNavy)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(
                      color: disabled
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFFCBD5E0)),
                  borderRadius: BorderRadius.circular(10),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: filled
                      ? Colors.white
                      : (disabled
                          ? const Color(0xFFCBD5E0)
                          : kNavy)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled
                      ? Colors.white
                      : (disabled
                          ? const Color(0xFFCBD5E0)
                          : kNavy),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
