import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class SafetyGuideScreen extends StatefulWidget {
  const SafetyGuideScreen({super.key});

  @override
  State<SafetyGuideScreen> createState() => _SafetyGuideScreenState();
}

class _SafetyGuideScreenState extends State<SafetyGuideScreen> {
  final Map<String, bool> _expanded = {
    'earthquake': true,
    'rain': true,
    'fire': true,
  };

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFf0f4f8),
      body: Column(
        children: [
          // 헤더
          Container(
            color: const Color(0xFF1a2744),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white70, size: 22),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      lang.t('guide_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    lang.t('guide_subtitle'),
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // 바디
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _GuideCategory(
                    id: 'earthquake',
                    title: lang.t('guide_earthquake'),
                    headerBg: const Color(0xFFf5f3ff),
                    iconBg: const Color(0xFFede9fe),
                    titleColor: const Color(0xFF4c1d95),
                    badgeBg: const Color(0xFFede9fe),
                    dotColor: const Color(0xFF7c3aed),
                    icon: Icons.show_chart,
                    iconColor: const Color(0xFF7c3aed),
                    isExpanded: _expanded['earthquake']!,
                    onToggle: () => setState(
                        () => _expanded['earthquake'] = !_expanded['earthquake']!),
                    tips: [
                      (lang.t('eq_tip1'), lang.t('eq_tip1_sub')),
                      (lang.t('eq_tip2'), lang.t('eq_tip2_sub')),
                      (lang.t('eq_tip3'), lang.t('eq_tip3_sub')),
                      (lang.t('eq_tip4'), lang.t('eq_tip4_sub')),
                      (lang.t('eq_tip5'), lang.t('eq_tip5_sub')),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _GuideCategory(
                    id: 'rain',
                    title: lang.t('guide_rain'),
                    headerBg: const Color(0xFFeff6ff),
                    iconBg: const Color(0xFFdbeafe),
                    titleColor: const Color(0xFF1e3a8a),
                    badgeBg: const Color(0xFFdbeafe),
                    dotColor: const Color(0xFF2563eb),
                    icon: Icons.water_drop_outlined,
                    iconColor: const Color(0xFF2563eb),
                    isExpanded: _expanded['rain']!,
                    onToggle: () => setState(
                        () => _expanded['rain'] = !_expanded['rain']!),
                    tips: [
                      (lang.t('rain_tip1'), lang.t('rain_tip1_sub')),
                      (lang.t('rain_tip2'), lang.t('rain_tip2_sub')),
                      (lang.t('rain_tip3'), lang.t('rain_tip3_sub')),
                      (lang.t('rain_tip4'), lang.t('rain_tip4_sub')),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _GuideCategory(
                    id: 'fire',
                    title: lang.t('guide_fire'),
                    headerBg: const Color(0xFFfff1f2),
                    iconBg: const Color(0xFFffe4e6),
                    titleColor: const Color(0xFF7f1d1d),
                    badgeBg: const Color(0xFFffe4e6),
                    dotColor: const Color(0xFFdc2626),
                    icon: Icons.local_fire_department_outlined,
                    iconColor: const Color(0xFFdc2626),
                    isExpanded: _expanded['fire']!,
                    onToggle: () => setState(
                        () => _expanded['fire'] = !_expanded['fire']!),
                    tips: [
                      (lang.t('fire_tip1'), lang.t('fire_tip1_sub')),
                      (lang.t('fire_tip2'), lang.t('fire_tip2_sub')),
                      (lang.t('fire_tip3'), lang.t('fire_tip3_sub')),
                      (lang.t('fire_tip4'), lang.t('fire_tip4_sub')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCategory extends StatelessWidget {
  final String id, title;
  final Color headerBg, iconBg, titleColor, badgeBg, dotColor, iconColor;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<(String, String)> tips;

  const _GuideCategory({
    required this.id,
    required this.title,
    required this.headerBg,
    required this.iconBg,
    required this.titleColor,
    required this.badgeBg,
    required this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.isExpanded,
    required this.onToggle,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        children: [
          // 헤더
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tips.length} tips',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: titleColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // 팁 목록
          if (isExpanded)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFe2e8f0))),
              ),
              child: Column(
                children: tips.asMap().entries.map((entry) {
                  final i = entry.key;
                  final tip = entry.value;
                  return Container(
                    decoration: BoxDecoration(
                      border: i < tips.length - 1
                          ? const Border(
                              bottom: BorderSide(color: Color(0xFFf1f5f9)))
                          : null,
                    ),
                    padding: const EdgeInsets.fromLTRB(30, 8, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, right: 8),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${tip.$1} ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1a2744),
                                  ),
                                ),
                                TextSpan(
                                  text: '— ${tip.$2}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}