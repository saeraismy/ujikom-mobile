import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Informasi>> fetchInformasi() async {
  try {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/posts'));
    print('Posts Response: ${response.body}'); // Debug print

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      
      List<Informasi> informasiList = [];
      
      for (var item in data) {
        if (item['category_id'] == 1) {
          try {
            print('Fetching gallery for post ${item['id']}'); // Debug print
            final galleryResponse = await http.get(
              Uri.parse('http://10.0.2.2:8000/api/galleries/by-post/${item['id']}')
            );
            print('Gallery Response for post ${item['id']}: ${galleryResponse.body}'); // Debug print

            if (galleryResponse.statusCode == 200) {
              Map<String, dynamic> galleryJson = json.decode(galleryResponse.body);
              item['gallery'] = galleryJson['data'];
            } else {
              print('Gallery fetch failed with status: ${galleryResponse.statusCode}');
              item['gallery'] = null;
            }
          } catch (e) {
            print('Error fetching gallery: $e');
            item['gallery'] = null;
          }
          
          informasiList.add(Informasi.fromJson(item));
        }
      }
      
      return informasiList;
    } else {
      print('Posts fetch failed with status: ${response.statusCode}');
      throw Exception('Failed to load Informasi: ${response.body}');
    }
  } catch (e) {
    print('Error in fetchInformasi: $e'); // Debug print
    throw Exception('Error fetching data: $e');
  }
}

class InformasiTab extends StatelessWidget {
  const InformasiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Informasi>>(
        future: fetchInformasi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan saat memuat data',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada informasi tersedia',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final informasiList = snapshot.data!;

          return Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: informasiList.length,
                itemBuilder: (context, index) {
                  Informasi informasi = informasiList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailInformasi(informasi: informasi),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF120A78).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.article_rounded,
                                    color: Color(0xFF120A78),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        informasi.judul,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF120A78),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _formatDate(informasi.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              informasi.isi.length > 100
                                  ? "${informasi.isi.substring(0, 100)}..."
                                  : informasi.isi,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    List<String> namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${dateTime.day} ${namaBulan[dateTime.month - 1]} ${dateTime.year}";
  }
}

class Informasi {
  final int id;
  final String judul;
  final String isi;
  final int categoryId;
  final String createdAt;
  final Gallery? gallery;

  Informasi({
    required this.id,
    required this.judul,
    required this.isi,
    required this.categoryId,
    required this.createdAt,
    this.gallery,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    return Informasi(
      id: json['id'],
      judul: json['judul'],
      isi: json['isi'],
      categoryId: json['category_id'],
      createdAt: json['created_at'],
      gallery: json['gallery'] != null ? Gallery.fromJson(json['gallery']) : null,
    );
  }
}

class Gallery {
  final int id;
  final String judul;
  final List<GalleryImage> images;

  Gallery({
    required this.id,
    required this.judul,
    required this.images,
  });

  factory Gallery.fromJson(Map<String, dynamic> json) {
    try {
      var imagesList = json['images'] as List? ?? [];
      List<GalleryImage> images = imagesList
          .map((imageJson) => GalleryImage.fromJson(imageJson))
          .toList();
      return Gallery(
        id: json['id'] ?? 0,
        judul: json['judul'] ?? '',
        images: images,
      );
    } catch (e) {
      print('Error parsing Gallery: $e');
      return Gallery(
        id: 0,
        judul: '',
        images: [],
      );
    }
  }
}

class GalleryImage {
  final int id;
  final int galleryId;
  final String file;
  final String judul;

  GalleryImage({
    required this.id,
    required this.galleryId,
    required this.file,
    required this.judul,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    try {
      return GalleryImage(
        id: json['id'] ?? 0,
        galleryId: json['gallery_id'] ?? 0,
        file: json['file'] ?? '',
        judul: json['judul'] ?? '',
      );
    } catch (e) {
      print('Error parsing GalleryImage: $e');
      return GalleryImage(
        id: 0,
        galleryId: 0,
        file: '',
        judul: '',
      );
    }
  }
}

class DetailInformasi extends StatelessWidget {
  final Informasi informasi;

  const DetailInformasi({Key? key, required this.informasi}) : super(key: key);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF120A78),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Informasi',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              Text(
                informasi.judul,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF120A78),
                ),
              ),
              SizedBox(height: 12),
              // Tanggal Publikasi
              Row(
                children: [
                  Text(
                    'Tanggal Publikasi: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _formatDate(informasi.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Gambar
              if (informasi.gallery != null &&
                  informasi.gallery!.images.isNotEmpty)
                Container(
                  height: 200, // Ukuran gambar lebih kecil karena di tengah konten
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Tambah rounded corner
                    child: Image.network(
                      'http://10.0.2.2:8000/images/${informasi.gallery!.images[0].file}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, 
                                     size: 50, 
                                     color: Colors.grey[400]),
                                SizedBox(height: 8),
                                Text('Gagal memuat gambar',
                                     style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              SizedBox(height: 20),
              // Garis pemisah
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[200],
              ),
              SizedBox(height: 20),
              // Isi informasi
              Text(
                informasi.isi,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
