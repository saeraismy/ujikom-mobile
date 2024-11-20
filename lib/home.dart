import 'package:flutter/material.dart';
import 'agenda.dart';
import 'informasi.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Daftar logo jurusan
  final List<Map<String, String>> jurusan = [
    {'image': 'assets/pplg.png', 'name': 'PPLG'},
    {'image': 'assets/tjkt.png', 'name': 'TJKT'},
    {'image': 'assets/tflm.png', 'name': 'TFLM'},
    {'image': 'assets/tkr.png', 'name': 'TKR'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            
            // Logo Jurusan Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[200]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kompetensi Keahlian',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF120A78),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: jurusan.map((item) => Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Image.asset(
                                  item['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['name']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF120A78),
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Agenda Preview
            _buildSectionPreview(
              title: 'Agenda Sekolah',
              futureData: fetchUpcomingAgenda(),
              itemBuilder: (agenda) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF120A78),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 18,
                                    color: Color(0xFF120A78),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _formatDate(agenda.tanggal),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                agenda.judul,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              buttonLabel: 'Lihat Semua ',
              tabIndex: 2,
            ),
            SizedBox(height: 20),

            // Informasi Preview
            _buildSectionPreview(
              title: 'Informasi Terkini',
              futureData: fetchInformasi(),
              itemBuilder: (informasi) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        informasi.judul,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        informasi.isi.length > 100 
                            ? '${informasi.isi.substring(0, 100)}...'
                            : informasi.isi,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              },
              buttonLabel: 'Lihat Semua ',
              tabIndex: 1,
            ),
            SizedBox(height: 20),

            // Denah Sekolah Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[200]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Denah Sekolah',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF120A78),
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        child: Image.asset(
                          'assets/denah_sekolah.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchUpcomingAgenda() async {
    List<dynamic> allAgendas = await fetchAgenda();
    DateTime now = DateTime.now();
    
    // Filter agenda yang akan datang
    var upcomingAgendas = allAgendas.where((agenda) {
      DateTime agendaDate = DateTime.parse(agenda.tanggal);
      return agendaDate.isAfter(now);
    }).toList();
    
    // Urutkan berdasarkan tanggal terdekat
    upcomingAgendas.sort((a, b) {
      DateTime dateA = DateTime.parse(a.tanggal);
      DateTime dateB = DateTime.parse(b.tanggal);
      return dateA.compareTo(dateB);
    });
    
    return upcomingAgendas;
  }

  Widget _buildSectionPreview({
  required String title,
  required Future<List<dynamic>> futureData,
  required Widget Function(dynamic item) itemBuilder,
  required String buttonLabel,
  required int tabIndex,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF120A78),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(tabIndex);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF120A78)),
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromARGB(255, 218, 221, 227),
                      ),
                      child: Row(
                        children: [
                          Text(
                            buttonLabel,
                            style: TextStyle(color: Color(0xFF120A78)),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Color(0xFF120A78),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[300], height: 16),
              SizedBox(height: 8),
              FutureBuilder<List<dynamic>>(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF120A78)),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 40),
                          SizedBox(height: 8),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, color: Colors.grey, size: 40),
                          SizedBox(height: 8),
                          Text('Belum ada data tersedia'),
                        ],
                      ),
                    );
                  }

                  final items = title == 'Informasi Terkini' 
                      ? snapshot.data!.take(1).toList()
                      : snapshot.data!.take(2).toList();

                  return Column(
                    children: items.map((item) {
                      if (title == 'Agenda Sekolah') {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFF120A78),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event,
                                            size: 18,
                                            color: Color(0xFF120A78),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            _formatDate(item.tanggal),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        item.judul,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.judul,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.isi.length > 100 
                                    ? '${item.isi.substring(0, 100)}...'
                                    : item.isi,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<List<dynamic>> fetchAgenda() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/posts'));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['data'];
    return data
        .where((item) => item['category_id'] == 2)
        .map((item) => Agenda.fromJson(item))
        .toList();
  }
  throw Exception('Failed to load agenda: ${response.body}');
}

Future<List<dynamic>> fetchInformasi() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/posts'));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['data'];
    return data
        .where((item) => item['category_id'] == 1)
        .map((item) => Informasi.fromJson(item))
        .toList();
  }
  throw Exception('Failed to load Informasi: ${response.body}');
}

String _formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  List<String> namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return "${dateTime.day} ${namaBulan[dateTime.month - 1]} ${dateTime.year}";
}

}
