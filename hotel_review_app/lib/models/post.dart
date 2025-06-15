// lib/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String statusText;
  final String? imageUrl; // Tetap ada, tapi akan selalu null
  final String? hotelName;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.statusText,
    this.imageUrl,
    this.hotelName,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  // Konversi dari Firestore DocumentSnapshot ke objek Post
  factory Post.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? 'Anonim',
      statusText: data['statusText'] ?? '',
      imageUrl: data['imageUrl'], // Akan menjadi null jika tidak ada di Firestore
      hotelName: data['hotelName'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Konversi objek Post ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'statusText': statusText,
      'imageUrl': imageUrl, // Akan menyimpan null
      'hotelName': hotelName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}