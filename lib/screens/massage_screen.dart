import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Kita perlu ini untuk format mata uang

// Import service dan model Anda
// Path ini mengasumsikan file ini ada di lib/screens/
import '../models/post.dart';
import '../client/rest_client.dart';
import '../services/post_service.dart';

class MassageScreen extends StatefulWidget {
  const MassageScreen({Key? key}) : super(key: key);

  @override
  _MassageScreenState createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> {
  late final PostService _postService;
  late Future<List<Post>> _futurePosts;

  // Buat formatter untuk mata uang IDR
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 0,
  );

@override
  void initState() {
    super.initState();
    // Inisialisasi service
    final restClient = RestClient(httpClient: http.Client());
    _postService = PostService(restClient); // <-- HAPUS "client:"

    // Panggil API
    _futurePosts = _postService.list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang abu-abu muda
      appBar: AppBar(
        title: const Text('Massage'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // Hilangkan bayangan appbar
      ),
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final posts = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                // Kirim data post ke widget card kustom kita
                return _buildMassageCard(post);
              },
            );
          }
          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }

  // Ini adalah widget untuk membuat card kustom
  // persis seperti di desain Anda
  Widget _buildMassageCard(Post post) {
    // Penjelasan pemetaan data ada di Bagian 2
    
    // Teks Judul (mapping dari post.title)
    String titleText = post.title.split(' ').first; // Ambil kata pertama
    
    // Teks Tanggal (mapping dari post.body)
    String dateText = post.body.split('\n').first; // Ambil baris pertama

    // Teks Harga (mapping dari post.id)
    double price = (post.id! * 50000).toDouble(); // Buat harga palsu
    String priceText = "+ ${currencyFormatter.format(price)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        // Warna border biru muda seperti di gambar
        border: Border.all(color: const Color(0xFFE0EFFF), width: 1.5), 
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kolom Kiri (Judul dan Tanggal)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0D182E), // Warna teks gelap
                  ),
                ),
                const SizedBox(height: 4),
               Text(
                  dateText, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle( // <-- HAPUS 'const'
                    fontSize: 13,
                    color: Colors.grey[600], 
                  ),
                ),
              ],
            ),
            
            // Kolom Kanan (Harga)
            Text(
              priceText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF00A86B), // Warna hijau
              ),
            ),
          ],
        ),
      ),
    );
  }
}