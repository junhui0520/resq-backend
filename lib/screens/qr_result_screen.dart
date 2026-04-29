import 'package:flutter/material.dart';

class QrResultScreen extends StatelessWidget {
  const QrResultScreen({super.key});

  final Color navy = const Color(0xFF243F73);
  final Color bg = const Color(0xFFF2F4FA);
  final Color textNavy = const Color(0xFF152A5C);
  final Color purple = const Color(0xFF777FC8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Column(
                  children: [
                    _profileCard(),
                    const SizedBox(height: 14),
                    _emergencyContactsCard(),
                    const SizedBox(height: 14),
                    _medicalInfoCard(),
                    const SizedBox(height: 14),
                    _warningBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: navy,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Scanned from SafeKorea',
                style: TextStyle(
                  color: Color(0xFFC9D3F1),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardStyle(),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: navy,
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'James Wilson',
                      style: TextStyle(
                        color: textNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '🇺🇸 United States ·',
                      style: TextStyle(
                        color: Color(0xFF777FC8),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Male · 28',
                      style: TextStyle(
                        color: Color(0xFF777FC8),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE5E7F2)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  title: 'BLOOD\nTYPE',
                  value: 'A+',
                  valueColor: const Color(0xFFC0392B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  title: 'NATIONALITY',
                  value: 'American',
                  valueColor: textNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFB2B6DA),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1.15,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emergencyContactsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('EMERGENCY CONTACTS'),
          const SizedBox(height: 12),
          _contactRow(
            name: 'Sarah Wilson',
            sub: 'Mother · +1-555-0192',
          ),
          const SizedBox(height: 12),
          _contactRow(
            name: 'US Embassy\nSeoul',
            sub: 'Embassy · 02-397-\n4114',
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required String name,
    required String sub,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: textNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                style: const TextStyle(
                  color: Color(0xFF8B92CF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Row(
            children: [
              Icon(Icons.call, color: Colors.white, size: 15),
              SizedBox(width: 5),
              Text(
                'Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _medicalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('MEDICAL INFO'),
          const SizedBox(height: 14),
          _subTitle('ALLERGIES'),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip('Penicillin', const Color(0xFFFFE5E5), const Color(0xFFC94A4A)),
              const SizedBox(width: 8),
              _chip('Peanuts', const Color(0xFFFFE5E5), const Color(0xFFC94A4A)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE5E7F2)),
          const SizedBox(height: 12),
          _subTitle('CONDITIONS'),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip('Asthma', const Color(0xFFE9E9FB), const Color(0xFF5D65B3)),
              const SizedBox(width: 8),
              _chip('Diabetes', const Color(0xFFE9E9FB), const Color(0xFF5D65B3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _warningBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD89C)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD36B2C),
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This information is\nprovided for emergency\nuse only. Please contact\nthe embassy if further\nassistance is needed.',
              style: TextStyle(
                color: Color(0xFFC1632A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8A91CD),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _subTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFB2B6DA),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _chip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE1E4EF)),
    );
  }
}