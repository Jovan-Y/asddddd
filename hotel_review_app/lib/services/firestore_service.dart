// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_review_app/models/post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan stream postingan dari Firestore
  Stream<List<Post>> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());
  }

  // Menambahkan postingan baru ke Firestore
  Future<void> addPost(Post post) {
    return _db.collection('posts').add(post.toMap());
  }
}