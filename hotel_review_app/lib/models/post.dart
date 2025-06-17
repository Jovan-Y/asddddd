// lib/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String? userName;
  final String statusText;
  final String? imageUrl;
  final DateTime timestamp;

  // -- Kolom Baru --
  final double rating;          // Rating bintang (misal: 4.5)
  final String? locationAddress; // Alamat hasil reverse geocoding
  final String? hotelName;
  final String? hotelPlaceId;    // ID unik hotel dari Google Places API

  Post({
    required this.id,
    required this.userId,
    this.userName,
    required this.statusText,
    this.imageUrl,
    required this.timestamp,
    // -- Parameter Baru --
    required this.rating,
    this.locationAddress,
    this.hotelName,
    this.hotelPlaceId,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? 'Anonim',
      userName: data['userName'],
      statusText: data['statusText'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      // -- Ambil Data Baru --
      rating: (data['rating'] ?? 0.0).toDouble(),
      locationAddress: data['locationAddress'],
      hotelName: data['hotelName'],
      hotelPlaceId: data['hotelPlaceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'statusText': statusText,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      // -- Simpan Data Baru --
      'rating': rating,
      'locationAddress': locationAddress,
      'hotelName': hotelName,
      'hotelPlaceId': hotelPlaceId,
    };
  }
}