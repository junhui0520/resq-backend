import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

const Color kNavy = Color(0xFF1B2F6E);

class EmbassyData {
  final String flag;
  final String country;
  final String address;
  final String phone;

  EmbassyData({
    required this.flag,
    required this.country,
    required this.address,
    required this.phone,
  });
}

class EmbassyPage extends StatefulWidget {
  const EmbassyPage({super.key});

  @override
  State<EmbassyPage> createState() => _EmbassyPageState();
}

class _EmbassyPageState extends State<EmbassyPage> {
  List<EmbassyData> embassyList = [];
  List<EmbassyData> filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCsv();
    _searchController.addListener(_onSearchChanged);
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
      filteredList = embassyList
          .where((e) => e.country.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> loadCsv() async {
    final rawData = await rootBundle.loadString('assets/embassy_utf8_C.txt');

    final csvTable = const CsvToListConverter(
      fieldDelimiter: '\t',
      shouldParseNumbers: false,
    ).convert(rawData);

    List<EmbassyData> tempList = [];

    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      if (row.length < 5) continue;

      final flag    = row[0].toString().trim();
      final country = row[1].toString().trim();
      final address = row[2].toString().trim();
      final phone   = row[4].toString().trim();

      tempList.add(EmbassyData(
        flag: flag,
        country: country,
        address: address,
        phone: phone,
      ));
    }

    setState(() {
      embassyList = tempList;
      filteredList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: kNavy,
        title: const Text(
          'Embassy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                hintText: 'Search country...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          _searchController.clear();
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

          // 리스트
          Expanded(
            child: embassyList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? const Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final data = filteredList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.flag,
                                  style: const TextStyle(fontSize: 30),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.country,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        data.address,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: kNavy,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        data.phone,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
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