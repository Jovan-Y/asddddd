// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:hotel_review_app/models/post.dart';
import 'package:hotel_review_app/services/firestore_service.dart';
import 'package:hotel_review_app/screens/add_post_screen.dart'; // Import AddPostScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Hotel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment), // Mengganti ikon karena tidak ada lagi unggah foto
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPostScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firestoreService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada ulasan. Mari mulai memposting!'));
          }

          List<Post> posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              Post post = posts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

// Widget untuk menampilkan satu postingan ulasan
class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userId.substring(0, 8) + '...', // Tampilkan sebagian kecil ID pengguna
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(post.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.statusText,
              style: const TextStyle(fontSize: 16),
            ),
            if (post.hotelName != null && post.hotelName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.hotel, size: 18, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Hotel: ${post.hotelName}',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            // Bagian Image.network akan tetap ada, tetapi hanya akan ditampilkan jika imageUrl tidak null
            // Karena kita tidak lagi mengunggah gambar, bagian ini mungkin tidak akan ditampilkan sama sekali
            // kecuali jika ada imageUrl yang disimpan sebelumnya di Firestore dari sumber lain.
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
            if (post.latitude != null && post.longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: SizedBox(
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(post.latitude!, post.longitude!),
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(post.id),
                          position: LatLng(post.latitude!, post.longitude!),
                        ),
                      },
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                    ),
                  ),
                ),
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () { /* TODO: Implement Like */ },
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('Suka'),
                ),
                TextButton.icon(
                  onPressed: () { /* TODO: Implement Comment */ },
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Komentar'),
                ),
                TextButton.icon(
                  onPressed: () { /* TODO: Implement Share */ },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Bagikan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}