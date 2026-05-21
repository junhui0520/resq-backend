class AppStrings {
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ja': '日本語',
    'zh': '中文',
    'vi': 'Tiếng Việt',
    'de': 'Deutsch',
  };

  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
    'vi': '🇻🇳',
    'de': '🇩🇪',
  };

  static const Map<String, String> defaultStrings = {
    // Settings
    'settings': 'Settings',
    'language': 'LANGUAGE',
    'notifications': 'NOTIFICATIONS',
    'about': 'ABOUT',
    'app_language': 'App language',
    'alert_translation': 'Alert translation',
    'emergency_alerts': 'Emergency alerts',
    'push_notifications': 'Push notifications',
    'alert_sound': 'Alert sound',
    'alarm_on_critical': 'Alarm on critical alerts',
    'region': 'Region',
    'my_alert_area': 'My alert area',
    'app_version': 'App version',
    // Nav
    'nav_home': 'Home',
    'nav_alerts': 'Alerts',
    'nav_embassy': 'Embassy',
    'nav_settings': 'Settings',
    // Home - Status
    'no_active_alerts': 'No active alerts',
    'area_safe': 'Your area is currently safe.\nStay prepared.',
    'all_clear': 'All clear · Cheonan',
    // Home - Quick Actions
    'quick_actions': 'QUICK ACTIONS',
    'call_119': 'Call 119 — Emergency',
    'fire_ambulance': 'Fire, ambulance, rescue',
    'safety_guide': 'Safety guide',
    'safety_guide_sub': 'Earthquake, rain, fire tips',
    // Home - Recent Alerts
    'recent_alerts': 'RECENT ALERTS',
    'no_recent_alerts': 'No recent alerts',
    // QR Screen
    'emergency_info': 'Emergency Info',
    'scanned_from': 'Scanned from SafeKorea',
    'qr_not_setup': 'No Emergency Info Set Up',
    'qr_not_setup_sub':
        'Set up your emergency profile so\nrescuers can help you faster.',
    'setup_my_info': 'Set Up My Info',
    'edit_my_info': 'Edit My Info',
    'qr_warning':
        'This information is provided for emergency use only. Please contact the embassy if further assistance is needed.',
    // QR Profile fields
    'blood_type': 'BLOOD TYPE',
    'nationality': 'NATIONALITY',
    'emergency_contacts': 'EMERGENCY CONTACTS',
    'medical_info': 'MEDICAL INFO',
    'allergies': 'ALLERGIES',
    'conditions': 'CONDITIONS',
    // Edit Sheet
    'name': 'NAME',
    'name_hint': 'Full name',
    'age': 'AGE',
    'age_hint': 'Your age',
    'nationality_hint': 'e.g. American',
    'gender': 'GENDER',
    'male': 'Male',
    'female': 'Female',
    'save': 'Save',

    // Safety Guide Screen
    'guide_title': 'Safety guide',
    'guide_subtitle': 'Earthquake · Rain · Fire',

    // 카테고리 제목
    'guide_earthquake': 'Earthquake',
    'guide_rain': 'Heavy rain',
    'guide_fire': 'Fire',

    // Earthquake tips
    'eq_tip1': 'Drop, cover, hold',
    'eq_tip1_sub': 'get under a sturdy table, protect your head',
    'eq_tip2': 'Stay away',
    'eq_tip2_sub': 'from windows and heavy furniture',
    'eq_tip3': 'No elevators',
    'eq_tip3_sub': 'use stairs after shaking stops',
    'eq_tip4': 'Check gas leaks',
    'eq_tip4_sub': 'before turning on lights after shaking',
    'eq_tip5': 'Move to open ground',
    'eq_tip5_sub': 'away from buildings',

    // Rain tips
    'rain_tip1': 'Avoid low-lying areas',
    'rain_tip1_sub': 'underpasses and riversides',
    'rain_tip2': 'Do not cross',
    'rain_tip2_sub': 'flooded roads or streams',
    'rain_tip3': 'Move valuables up',
    'rain_tip3_sub': 'to higher floors if flooding is likely',
    'rain_tip4': 'Follow alerts',
    'rain_tip4_sub': 'monitor SafeKorea and evacuation orders',

    // Fire tips
    'fire_tip1': 'Call 119 immediately',
    'fire_tip1_sub': 'do not try to fight a large fire',
    'fire_tip2': 'Crawl low under smoke',
    'fire_tip2_sub': 'stay below the smoke line',
    'fire_tip3': 'Close doors',
    'fire_tip3_sub': 'slow fire spread; do not use elevators',
    'fire_tip4': 'Assembly point',
    'fire_tip4_sub': 'gather at the designated spot outside',

    // Call 119 Screen
    'call_title': 'Emergency Call',
    'call_subtitle': 'Korea emergency services',
    'call_119_desc': 'Fire · Ambulance · Rescue',
    'tap_to_call': 'Tap to call 119',
    'other_numbers': 'OTHER EMERGENCY NUMBERS',
    'police_112': '112 — Police',
    'police_112_sub': 'Crime, assault, theft',
    'medical_1339': '1339 — Medical hotline',
    'medical_1339_sub': '24h health consultation',
    'nearby_hospitals': 'Nearby hospitals',
    'nearby_hospitals_sub': 'Open ER map',
    'call_tip_title': 'TIP — When calling 119',
    'call_tip_body':
        'Say your location first · Stay calm · Keep the line open until help arrives',
  };
}
