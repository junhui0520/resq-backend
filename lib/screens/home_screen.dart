import 'package:flutter/material.dart';
import 'qr_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasEmergency = false;

  final Color navy = const Color(0xFF243F73);
  final Color bg = const Color(0xFFF2F4FA);
  final Color textNavy = const Color(0xFF152A5C);
  final Color subText = const Color(0xFF737BC8);

  @override
  void initState() {
    super.initState();
    fetchAlert();
  }

  void fetchAlert() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      hasEmergency = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    hasEmergency ? _dangerCard() : _safeCard(),
                    const SizedBox(height: 18),
                    _sectionTitle('QUICK ACTIONS'),
                    const SizedBox(height: 10),
                    _call119Card(),
                    const SizedBox(height: 12),
                    _safetyGuideCard(),
                    const SizedBox(height: 18),
                    _sectionTitle('RECENT ALERTS'),
                    const SizedBox(height: 10),
                    _alertCard(
                      color: const Color(0xFFFFC56D),
                      title: 'High PM2.5\nadvisory',
                      tag: 'Air',
                      content: 'Seoul metro ·\nResolved',
                      time: 'Yesterday',
                    ),
                    const SizedBox(height: 12),
                    _alertCard(
                      color: const Color(0xFF90C8FF),
                      title: 'Strong wind\nadvisory',
                      tag: 'Wind',
                      content: 'Chungnam ·\nResolved',
                      time: '3 days ago',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _header() {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      color: navy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ResQ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QrResultScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_2, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'My QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _safeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9CD28F), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF3F8F40), size: 13),
              const SizedBox(width: 12),
              Text(
                'No active alerts',
                style: TextStyle(
                  color: textNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your area is currently safe.\nStay prepared.',
            style: TextStyle(
              color: Color(0xFF30394F),
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFD3EFCB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'All clear · Cheonan',
              style: TextStyle(
                color: Color(0xFF3C7635),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dangerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE58E8E), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.circle, color: Color(0xFFC0392B), size: 13),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Heavy rain warning',
                  style: TextStyle(
                    color: Color(0xFFB12B2B),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Issued 09:38 · Avoid low-\nlying areas and prepare for\nevacuation.',
            style: TextStyle(
              color: Color(0xFF7A2020),
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCFCF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Active · Cheonan',
              style: TextStyle(
                color: Color(0xFFB12B2B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6F77C8),
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
    );
  }

  Widget _call119Card() {
    return GestureDetector(
      onTap: () {
        // 추후 url_launcher로 119 전화 연결
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.call, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Call 119 —\nEmergency',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Fire, ambulance,\nrescue',
                    style: TextStyle(
                      color: Color(0xFFCCD5F0),
                      fontSize: 15,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB9C7EC), size: 32),
          ],
        ),
      ),
    );
  }

  Widget _safetyGuideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6DAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book, color: navy, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety guide',
                  style: TextStyle(
                    color: textNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Earthquake, rain,\nfire tips',
                  style: TextStyle(
                    color: Color(0xFF6F77C8),
                    fontSize: 16,
                    height: 1.05,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFA7AEE0), size: 32),
        ],
      ),
    );
  }

  Widget _alertCard({
    required Color color,
    required String title,
    required String tag,
    required String content,
    required String time,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E4EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 78,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        content,
                        style: const TextStyle(
                          color: Color(0xFF737BC8),
                          fontSize: 14,
                          height: 1.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF9AA1DC),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE1E4EF)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home', true),
          _navItem(Icons.star_border, 'Alerts', false),
          _navItem(Icons.credit_card, 'Embassy', false),
          _navItem(Icons.wb_sunny_outlined, 'Settings', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? textNavy : const Color(0xFF9EA6E1),
          size: 28,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: active ? textNavy : const Color(0xFF9EA6E1),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: textNavy,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}