// lib/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String? userName; // TAMBAHKAN INI
  final String statusText;
  final String? imageUrl;
  final String? hotelName;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    this.userName, // TAMBAHKAN INI
    required this.statusText,
    this.imageUrl,
    this.hotelName,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? 'Anonim',
      userName: data['userName'], // TAMBAHKAN INI
      statusText: data['statusText'] ?? '',
      imageUrl: data['imageUrl'],
      hotelName: data['hotelName'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName, // TAMBAHKAN INI
      'statusText': statusText,
      'imageUrl': imageUrl,
      'hotelName': hotelName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}