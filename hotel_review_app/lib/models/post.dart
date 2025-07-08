
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String? userName;
  final String statusText;
  final String? imageUrl; 
  final DateTime timestamp;
  final double rating;
  final String? locationAddress;
  final String? hotelName;
  final String? hotelOsmId;
  final List<String> likes;

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
    this.hotelOsmId,
    required this.likes,
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
      hotelOsmId: data['hotelOsmId'],
      likes: List<String>.from(data['likes'] ?? []),
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
      'hotelOsmId': hotelOsmId,
      'likes': likes,
    };
  }
}
