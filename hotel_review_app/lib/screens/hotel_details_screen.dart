// lib/screens/hotel_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hotel_review_app/models/post.dart';
import 'package:hotel_review_app/services/firestore_service.dart';
import 'package:hotel_review_app/screens/home_screen.dart'; // Mengimpor PostCard

class HotelDetailsScreen extends StatelessWidget {
  final String hotelName;
  final String hotelOsmId;

  const HotelDetailsScreen({
    super.key,
    required this.hotelName,
    required this.hotelOsmId,
  });

  @override
  Widget build(BuildContext context) {
    // Membuat instance dari FirestoreService
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(hotelName),
      ),
      body: StreamBuilder<List<Post>>(
        stream: firestoreService.getPostsForHotel(hotelOsmId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada ulasan untuk hotel ini.'));
          }

          final posts = snapshot.data!;
          double totalRating = posts.fold(0, (sum, item) => sum + item.rating);
          double averageRating = posts.isNotEmpty ? totalRating / posts.length : 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Rating Rata-rata', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    RatingBarIndicator(
                      rating: averageRating,
                      itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 30.0,
                    ),
                    Text('Berdasarkan ${posts.length} ulasan'),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    // **PERBAIKAN:** Menambahkan argumen firestoreService yang diperlukan
                    return PostCard(
                      post: posts[index],
                      firestoreService: firestoreService,
                      showHotelName: false,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
