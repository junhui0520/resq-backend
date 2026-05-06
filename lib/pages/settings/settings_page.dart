import 'package:flutter/material.dart';

const Color kNavy = Color(0xFF1B2F6E);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emergencyAlerts = true;
  bool _alertSound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── LANGUAGE ─────────────────────────────────────
          _SectionLabel('LANGUAGE'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _TileWithChip(
                icon: Icons.language,
                iconBg: const Color(0xFFE8EAF6),
                iconColor: const Color(0xFF5C6BC0),
                title: 'App language',
                subtitle: 'Alert translation',
                chipLabel: 'English',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── NOTIFICATIONS ────────────────────────────────
          _SectionLabel('NOTIFICATIONS'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _TileWithToggle(
                icon: Icons.notifications_outlined,
                iconBg: const Color(0xFFFFEBEE),
                iconColor: const Color(0xFFE53935),
                title: 'Emergency alerts',
                subtitle: 'Push notifications',
                value: _emergencyAlerts,
                onChanged: (v) => setState(() => _emergencyAlerts = v),
              ),
              const _Divider(),
              _TileWithToggle(
                icon: Icons.star_border,
                iconBg: const Color(0xFFFFF8E1),
                iconColor: const Color(0xFFFFB300),
                title: 'Alert sound',
                subtitle: 'Alarm on critical alerts',
                value: _alertSound,
                onChanged: (v) => setState(() => _alertSound = v),
              ),
              const _Divider(),
              _TileWithChip(
                icon: Icons.location_on_outlined,
                iconBg: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF43A047),
                title: 'Region',
                subtitle: 'My alert area',
                chipLabel: 'Cheonan',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── ABOUT ────────────────────────────────────────
          _SectionLabel('ABOUT'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _TileAbout(
                icon: Icons.info_outline,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF1E88E5),
                title: 'App version',
                subtitle: 'SafeKorea',
                trailing: 'v1.0.0',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700, color: kNavy, letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 68, color: Color(0xFFF0F2F5));
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;
  const _IconBox({required this.icon, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _TileWithToggle extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TileWithToggle({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon, bg: iconBg, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kNavy)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
            ]),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: kNavy,
          ),
        ],
      ),
    );
  }
}

class _TileWithChip extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String chipLabel;
  final VoidCallback onTap;

  const _TileWithChip({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon: icon, bg: iconBg, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kNavy)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(chipLabel,
                  style: const TextStyle(fontSize: 13, color: kNavy, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E0), size: 20),
          ],
        ),
      ),
    );
  }
}

class _TileAbout extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;

  const _TileAbout({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon, bg: iconBg, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kNavy)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
            ]),
          ),
          Text(trailing, style: const TextStyle(fontSize: 13, color: Color(0xFF9AA5B4))),
        ],
      ),
    );
  }
}
