// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:hotel_review_app/models/post.dart';
import 'package:hotel_review_app/screens/profile_screen.dart';
import 'package:hotel_review_app/services/firestore_service.dart';
import 'package:hotel_review_app/screens/add_post_screen.dart';
import 'package:hotel_review_app/screens/hotel_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Hotel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPostScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: firestoreService.getPosts(),
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
              // Di sini pemanggilan PostCard tidak perlu diubah karena
              // showHotelName sudah default ke true.
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  // --- PERUBAHAN DI SINI ---
  final bool showHotelName; // 1. Tambahkan variabel ini

  // 2. Perbarui konstruktor untuk menerima parameter baru
  const PostCard({
    super.key,
    required this.post,
    this.showHotelName = true, // Beri nilai default true
  });
  // --- AKHIR PERUBAHAN ---

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
                        post.userName ?? 'User (${post.userId.substring(0, 6)})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd MMM yy, HH:mm').format(post.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // --- GUNAKAN PARAMETER BARU DI SINI ---
            if (showHotelName && post.hotelName != null)
              InkWell(
                onTap: () {
                  if (post.hotelPlaceId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelDetailsScreen(
                          hotelName: post.hotelName!,
                          hotelPlaceId: post.hotelPlaceId!,
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.hotelName!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                    ),
                    const SizedBox(height: 4),
                    RatingBarIndicator(
                      rating: post.rating,
                      itemBuilder: (context, index) =>
                          const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              post.statusText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (post.locationAddress != null)
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      post.locationAddress!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('Suka'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Komentar'),
                ),
                TextButton.icon(
                  onPressed: () {},
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