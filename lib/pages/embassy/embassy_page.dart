import 'package:flutter/material.dart';

const Color kNavy = Color(0xFF1B2F6E);

class _EmbassyData {
  final String flag;
  final String country;
  final String address;
  final String phone;

  const _EmbassyData({
    required this.flag,
    required this.country,
    required this.address,
    required this.phone,
  });
}

const List<_EmbassyData> _embassies = [
  _EmbassyData(flag: '🇺🇸', country: 'United States', address: 'Jongno-gu, Seoul', phone: '02-397-4114'),
  _EmbassyData(flag: '🇨🇳', country: 'China',         address: 'Myeongdong, Seoul', phone: '02-738-1038'),
  _EmbassyData(flag: '🇯🇵', country: 'Japan',         address: 'Yongsan-gu, Seoul', phone: '02-2170-5200'),
  _EmbassyData(flag: '🇩🇪', country: 'Germany',       address: 'Yongsan-gu, Seoul', phone: '02-748-4114'),
  _EmbassyData(flag: '🇫🇷', country: 'France',        address: 'Seodaemun-gu, Seoul', phone: '02-3149-4300'),
  _EmbassyData(flag: '🇬🇧', country: 'United Kingdom',address: 'Jongno-gu, Seoul', phone: '02-3210-5500'),
  _EmbassyData(flag: '🇦🇺', country: 'Australia',     address: 'Mapo-gu, Seoul', phone: '02-2003-0100'),
  _EmbassyData(flag: '🇨🇦', country: 'Canada',        address: 'Jung-gu, Seoul', phone: '02-3783-6000'),
];

class EmbassyPage extends StatefulWidget {
  const EmbassyPage({super.key});

  @override
  State<EmbassyPage> createState() => _EmbassyPageState();
}

class _EmbassyPageState extends State<EmbassyPage> {
  String _query = '';

  List<_EmbassyData> get _filtered => _embassies
      .where((e) => e.country.toLowerCase().contains(_query.toLowerCase()))
      .toList();

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
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 검색창
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: const TextStyle(color: Color(0xFFB0B8C8), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB0B8C8), size: 20),
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
          // 목록
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _EmbassyCard(data: _filtered[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmbassyCard extends StatelessWidget {
  final _EmbassyData data;
  const _EmbassyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(data.flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.country,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.address} · ${data.phone}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                    ),
                  ],
                ),
              ),
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
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.location_on_outlined,
                  label: 'Directions',
                  filled: false,
                  onTap: () {},
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
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? kNavy : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E0)),
                  borderRadius: BorderRadius.circular(10),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: filled ? Colors.white : kNavy),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : kNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
