import 'package:flutter/material.dart';
import 'agenda.dart';
import 'informasi.dart';
import 'galery.dart';
import 'home.dart';

class TabScreen extends StatelessWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'SMKN 4 BOGOR',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF120A78),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logoSMKN4.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            HomeTab(),
            InformasiTab(),
            AgendaTab(),
            GalleryTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                text: 'Home',
              ),
              Tab(
                icon: Icon(Icons.info),
                text: 'Informasi',
              ),
              Tab(
                icon: Icon(Icons.event),
                text: 'Agenda',
              ),
              Tab(
                icon: Icon(Icons.photo),
                text: 'Galeri',
              ),
            ],
            labelColor: Color(0xFF120A78),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF120A78),
          ),
        ),
      ),
    );
  }
}
