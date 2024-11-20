import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Agenda>> fetchAgenda() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/posts'));

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['data'];
    return data
        .where((item) => item['category_id'] == 2)
        .map((item) => Agenda.fromJson(item))
        .toList();
  } else {
    throw Exception('Failed to load agenda: ${response.body}');
  }
}

class AgendaTab extends StatefulWidget {
  const AgendaTab({Key? key}) : super(key: key);

  @override
  State<AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<AgendaTab> {
  DateTime selectedMonth = DateTime.now();

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    List<String> namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${dateTime.day} ${namaBulan[dateTime.month - 1]} ${dateTime.year}";
  }

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  Map<DateTime, List<Agenda>> _groupAgendaByDate(List<Agenda> agendas) {
    Map<DateTime, List<Agenda>> grouped = {};
    for (var agenda in agendas) {
      DateTime date = DateTime.parse(agenda.tanggal);
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(agenda);
    }
    return grouped;
  }

  void _showAgendaDialog(BuildContext context, DateTime date, List<Agenda> agendas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(date.toString()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF120A78),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(thickness: 1),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: agendas.length,
                    itemBuilder: (context, index) {
                      final agenda = agendas[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailAgenda(agenda: agenda),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF120A78),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      agenda.judul,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      agenda.isi.length > 50
                                          ? '${agenda.isi.substring(0, 50)}...'
                                          : agenda.isi,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Agenda>>(
        future: fetchAgenda(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada agenda tersedia'));
          }

          final agendaList = snapshot.data!;
          final groupedAgendas = _groupAgendaByDate(agendaList);
          final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '${_formatDate(selectedMonth.toString().split(' ')[0])}'.split(' ')[1] + 
                      ' ${selectedMonth.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
              // Hari-hari dalam seminggu
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text('Min', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Sen', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Sel', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rab', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Kam', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Jum', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Sab', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              // Grid kalender
              Expanded(
                flex: 2,  // Memberikan flex lebih besar untuk kalender
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: 42, // 6 minggu x 7 hari
                  itemBuilder: (context, index) {
                    // Mendapatkan hari pertama dalam bulan
                    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
                    final firstWeekdayOfMonth = firstDayOfMonth.weekday;
                    
                    // Mengatur offset agar Minggu dimulai dari 0
                    final offset = firstWeekdayOfMonth == 7 ? 0 : firstWeekdayOfMonth;
                    
                    // Menghitung tanggal yang sebenarnya
                    final dayNumber = index - offset;
                    final currentDate = DateTime(selectedMonth.year, selectedMonth.month, dayNumber + 1);
                    
                    // Mengecek apakah tanggal valid untuk bulan ini
                    final isValidDate = dayNumber >= 0 && 
                        currentDate.month == selectedMonth.month;
                    
                    if (!isValidDate) {
                      return Container(); // Sel kosong untuk tanggal di luar bulan
                    }

                    final hasAgenda = groupedAgendas.containsKey(currentDate);
                    final isToday = currentDate.day == DateTime.now().day && 
                                  currentDate.month == DateTime.now().month &&
                                  currentDate.year == DateTime.now().year;

                    return InkWell(
                      onTap: hasAgenda ? () {
                        _showAgendaDialog(context, currentDate, groupedAgendas[currentDate]!);
                      } : null,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isToday 
                              ? const Color(0xFF120A78)
                              : hasAgenda 
                                  ? const Color(0xFF120A78).withOpacity(0.1)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasAgenda 
                                ? const Color(0xFF120A78)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${currentDate.day}',
                                style: TextStyle(
                                  color: isToday 
                                      ? Colors.white
                                      : hasAgenda 
                                          ? const Color(0xFF120A78)
                                          : Colors.black,
                                  fontWeight: hasAgenda || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (hasAgenda)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: isToday 
                                        ? Colors.white
                                        : const Color(0xFF120A78),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Card Agenda dengan jarak yang lebih dekat
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25, // Mengatur tinggi card
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: 8,  // Mengurangi margin atas
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF120A78).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event_note,
                            color: Color(0xFF120A78),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Agenda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF120A78),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(  // Menggunakan Expanded untuk ListView
                      child: ListView.builder(
                        itemCount: agendaList.where((agenda) {
                          DateTime agendaDate = DateTime.parse(agenda.tanggal);
                          return agendaDate.year == selectedMonth.year &&
                                 agendaDate.month == selectedMonth.month;
                        }).length,
                        itemBuilder: (context, index) {
                          List<Agenda> monthlyAgendas = agendaList.where((agenda) {
                            DateTime agendaDate = DateTime.parse(agenda.tanggal);
                            return agendaDate.year == selectedMonth.year &&
                                   agendaDate.month == selectedMonth.month;
                          }).toList();
                          
                          if (monthlyAgendas.isEmpty) {
                            return const Center(
                              child: Text('Tidak ada agenda bulan ini'),
                            );
                          }

                          final agenda = monthlyAgendas[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailAgenda(agenda: agenda),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF120A78),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          agenda.judul,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(agenda.tanggal),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF120A78),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Tambahkan class DetailAgenda
class DetailAgenda extends StatelessWidget {
  final Agenda agenda;

  const DetailAgenda({Key? key, required this.agenda}) : super(key: key);

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    List<String> namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${dateTime.day} ${namaBulan[dateTime.month - 1]} ${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF120A78),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Agenda',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF120A78).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.event,
                            color: Color(0xFF120A78),
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            agenda.judul,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF120A78),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        agenda.isi,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model for Agenda data
class Agenda {
  final int id;
  final String judul;
  final String isi;
  final int categoryId;
  final String createdAt;
  final String tanggal;

  Agenda({
    required this.id,
    required this.judul,
    required this.isi,
    required this.categoryId,
    required this.createdAt,
    required this.tanggal,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      id: json['id'],
      judul: json['judul'],
      isi: json['isi'],
      categoryId: json['category_id'],
      createdAt: json['created_at'],
      tanggal: json['tanggal'],
    );
  }
}
