// lib/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String? userName;
  final String statusText;
  final String? imageUrl;
  final DateTime timestamp;

  // -- Kolom yang Diperbarui --
  final double rating;
  final String? locationAddress;
  final String? hotelName;
  final String? hotelOsmId;    // Diubah dari hotelPlaceId

  Post({
    required this.id,
    required this.userId,
    this.userName,
    required this.statusText,
    this.imageUrl,
    required this.timestamp,
    required this.rating,
    this.locationAddress,
    this.hotelName,
    this.hotelOsmId, // Diubah dari hotelPlaceId
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
      rating: (data['rating'] ?? 0.0).toDouble(),
      locationAddress: data['locationAddress'],
      hotelName: data['hotelName'],
      hotelOsmId: data['hotelOsmId'], // Mengambil hotelOsmId dari Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'statusText': statusText,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'rating': rating,
      'locationAddress': locationAddress,
      'hotelName': hotelName,
      'hotelOsmId': hotelOsmId, // Menyimpan hotelOsmId ke Firestore
    };
  }
}