import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Gallery {
  final int id;
  final String title;
  final String status;
  final List<GalleryImage> images;

  Gallery({
    required this.id,
    required this.title,
    required this.status,
    required this.images,
  });

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: json['id'] ?? 0,
      title: json['post']['judul']?.toString() ?? 'Galeri',
      status: json['status']?.toString() ?? '',
      images: [],
    );
  }
}

class GalleryImage {
  final int id;
  final int galleryId;
  final String judul;
  final String imgUrl;

  GalleryImage({
    required this.id,
    required this.galleryId,
    required this.judul,
    required this.imgUrl,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    String baseUrl = 'http://10.0.2.2:8000/images/';
    return GalleryImage(
      id: json['id'] ?? 0,
      galleryId: json['gallery_id'] ?? 0,
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      imgUrl: baseUrl + (json['file']?.toString() ?? ''),
    );
  }
}

Future<List<Gallery>> fetchGalleries() async {
  final galleriesResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/galleries'));
  
  if (galleriesResponse.statusCode != 200) {
    throw Exception('Failed to load galleries');
  }

  final imagesResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/images'));
  
  if (imagesResponse.statusCode != 200) {
    throw Exception('Failed to load images');
  }

  final List<dynamic> galleriesJson = json.decode(galleriesResponse.body)['data'];
  final List<dynamic> imagesJson = json.decode(imagesResponse.body)['data'];

  Map<int, Gallery> galleries = {
    for (var gallery in galleriesJson
        .map((g) => Gallery.fromJson(g))
        .where((g) => g.status.toLowerCase() == 'aktif'))
      gallery.id: gallery
  };

  for (var imageJson in imagesJson) {
    final image = GalleryImage.fromJson(imageJson);
    if (galleries.containsKey(image.galleryId)) {
      galleries[image.galleryId]!.images.add(image);
    }
  }

  return galleries.values.where((gallery) => gallery.images.isNotEmpty).toList();
}

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Gallery>>(
        future: fetchGalleries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data tersedia'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final gallery = snapshot.data![index];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryDetailScreen(gallery: gallery),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: gallery.images.isNotEmpty
                                ? gallery.images.length >= 3
                                    ? Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Image.network(
                                              gallery.images[0].imgUrl,
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(color: Colors.white, width: 1),
                                                        left: BorderSide(color: Colors.white, width: 1),
                                                      ),
                                                    ),
                                                    child: Image.network(
                                                      gallery.images[1].imgUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        left: BorderSide(color: Colors.white, width: 1),
                                                      ),
                                                    ),
                                                    child: Image.network(
                                                      gallery.images[2].imgUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Image.network(
                                        gallery.images[0].imgUrl,
                                        fit: BoxFit.cover,
                                      )
                                : const Icon(
                                    Icons.photo_library,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gallery.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gallery.images.length} foto',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class GalleryDetailScreen extends StatelessWidget {
  final Gallery gallery;

  const GalleryDetailScreen({super.key, required this.gallery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gallery.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.0,
          ),
          itemCount: gallery.images.length,
          itemBuilder: (context, index) {
            final image = gallery.images[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              image.imgUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              image.judul,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image.imgUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}