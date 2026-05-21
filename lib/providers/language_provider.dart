import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../services/translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLang = 'en';
  bool _isLoading = false;
  Map<String, String> _strings = Map.from(AppStrings.defaultStrings);

  // 번역 캐시 (언어코드 → 번역된 strings 맵)
  final Map<String, Map<String, String>> _cache = {
    'en': Map.from(AppStrings.defaultStrings),
  };

  String get currentLang => _currentLang;
  bool get isLoading => _isLoading;
  String get currentLangName => AppStrings.languageNames[_currentLang] ?? 'English';
  String get currentFlag => AppStrings.languageFlags[_currentLang] ?? '🇺🇸';

  /// 번역된 텍스트 반환 (키 없으면 영어 기본값)
  String t(String key) => _strings[key] ?? AppStrings.defaultStrings[key] ?? key;

  /// 앱 시작 시 저장된 언어 불러오기
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_language') ?? 'en';
    if (savedLang != 'en') {
      await setLanguage(savedLang);
    }
  }

  /// 언어 변경
  Future<void> setLanguage(String langCode) async {
    if (langCode == _currentLang) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_cache.containsKey(langCode)) {
        // 캐시에 있으면 즉시 적용
        _strings = _cache[langCode]!;
      } else {
        // API 호출 후 캐시 저장
        final translated = await TranslationService.translateAll(
          texts: AppStrings.defaultStrings,
          targetLang: langCode,
        );
        _cache[langCode] = translated;
        _strings = translated;
      }

      _currentLang = langCode;

      // 기기에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', langCode);
    } catch (_) {
      // 실패 시 영어 유지
      _strings = Map.from(AppStrings.defaultStrings);
      _currentLang = 'en';
    }

    _isLoading = false;
    notifyListeners();
  }
}
 