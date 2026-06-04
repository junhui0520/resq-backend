import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';

const Color kNavy = Color(0xFF1B2F6E);

class EmbassyData {
  final String flag;
  final String country;      // 원본 영어
  final String address;      // 원본 영어
  final String phone;
  String translatedCountry;  // 번역된 공관명
  String translatedAddress;  // 번역된 주소

  EmbassyData({
    required this.flag,
    required this.country,
    required this.address,
    required this.phone,
    String? translatedCountry,
    String? translatedAddress,
  })  : translatedCountry = translatedCountry ?? country,
        translatedAddress = translatedAddress ?? address;
}

class EmbassyPage extends StatefulWidget {
  const EmbassyPage({super.key});

  @override
  State<EmbassyPage> createState() => _EmbassyPageState();
}

class _EmbassyPageState extends State<EmbassyPage> {
  List<EmbassyData> _embassyList = [];
  List<EmbassyData> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isTranslating = false;
  String _lastLang = 'en';

  // 번역 캐시: {lang: {country: translatedCountry}}
  final Map<String, Map<String, String>> _countryCache = {};
  final Map<String, Map<String, String>> _addressCache = {};

  @override
  void initState() {
    super.initState();
    _loadCsv();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = context.read<LanguageProvider>().currentLang;
    if (_lastLang != currentLang && _embassyList.isNotEmpty) {
      _lastLang = currentLang;
      _translateEmbassies(currentLang);
    } else {
      _lastLang = currentLang;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _embassyList.where((e) =>
        e.translatedCountry.toLowerCase().contains(query) ||
        e.country.toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> _loadCsv() async {
    final rawData = await rootBundle.loadString('assets/embassy_utf8_C.txt');
    final csvTable = const CsvToListConverter(
      fieldDelimiter: '\t',
      shouldParseNumbers: false,
    ).convert(rawData);

    List<EmbassyData> tempList = [];
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      if (row.length < 5) continue;
      tempList.add(EmbassyData(
        flag:    row[0].toString().trim(),
        country: row[1].toString().trim(),
        address: row[2].toString().trim(),
        phone:   row[4].toString().trim(),
      ));
    }

    setState(() {
      _embassyList = tempList;
      _filteredList = tempList;
    });

    // 로드 후 현재 언어로 번역
    final lang = context.read<LanguageProvider>().currentLang;
    _lastLang = lang;
    if (lang != 'en') {
      _translateEmbassies(lang);
    }
  }

  // Google Translate 비공식 API
  Future<String> _translateText(String text, String targetLang) async {
    if (text.isEmpty || targetLang == 'en') return text;
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=en&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final buffer = StringBuffer();
        for (final item in data[0]) {
          if (item[0] != null) buffer.write(item[0]);
        }
        return buffer.toString();
      }
    } catch (_) {}
    return text;
  }

Future<void> _translateEmbassies(String lang) async {
  if (lang == 'en') {
    setState(() {
      for (final e in _embassyList) {
        e.translatedCountry = e.country;
        e.translatedAddress = e.address;
      }
      _filteredList = List.from(_embassyList);
    });
    return;
  }

  setState(() => _isTranslating = true);

  // SharedPreferences 캐시 확인
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'embassy_cache_$lang';
  final cached = prefs.getString(cacheKey);
  if (cached != null) {
    try {
      final Map<String, dynamic> cacheData = jsonDecode(cached);
      setState(() {
        for (final e in _embassyList) {
          e.translatedCountry = cacheData['c_${e.country}'] ?? e.country;
          e.translatedAddress = cacheData['a_${e.country}'] ?? e.address;
        }
        _filteredList = List.from(_embassyList);
        _isTranslating = false;
      });
      return;
    } catch (_) {}
  }

  // ✅ 10개씩 묶어서 동시에 번역 (병렬)
  const batchSize = 10;
  final Map<String, dynamic> newCache = {};

  for (int i = 0; i < _embassyList.length; i += batchSize) {
    if (_lastLang != lang) break; // 언어 바뀌면 중단

    final batch = _embassyList.sublist(
      i,
      (i + batchSize).clamp(0, _embassyList.length),
    );

    // 배치 내에서 country/address 동시 번역
    final futures = batch.map((e) async {
      final tCountry = await _translateText(e.country, lang);
      final tAddress = await _translateText(e.address, lang);
      return {e: (tCountry, tAddress)};
    });

    final results = await Future.wait(futures);

    for (final result in results) {
      result.forEach((e, translated) {
        e.translatedCountry = translated.$1;
        e.translatedAddress = translated.$2;
        newCache['c_${e.country}'] = translated.$1;
        newCache['a_${e.country}'] = translated.$2;
      });
    }

    // 배치 완료마다 UI 업데이트
    setState(() => _filteredList = List.from(_embassyList));
  }

  if (newCache.isNotEmpty) {
    await prefs.setString(cacheKey, jsonEncode(newCache));
  }

  setState(() => _isTranslating = false);
}

  Future<void> _call(String phone) async {
    // url_launcher 사용
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: kNavy,
        title: Row(
          children: [
            Text(
              lang.t('nav_embassy'),
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold,
              ),
            ),
            if (_isTranslating) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white60, strokeWidth: 2,
                ),
              ),
            ],
          ],
        ),
      ),
      body: Column(
        children: [
          // 검색창
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: lang.t('embassy_search_hint'),
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () => _searchController.clear(),
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

          // 리스트
          Expanded(
            child: _embassyList.isEmpty
                ? const Center(child: CircularProgressIndicator(color: kNavy))
                : _filteredList.isEmpty
                    ? Center(
                        child: Text(
                          lang.t('embassy_no_results'),
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final data = _filteredList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.flag,
                                    style: const TextStyle(fontSize: 30)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.translatedCountry,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 14, color: kNavy),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              data.translatedAddress,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: kNavy,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => _call(data.phone),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: kNavy.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.call,
                                                  size: 14, color: kNavy),
                                              const SizedBox(width: 6),
                                              Text(
                                                data.phone,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: kNavy,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
