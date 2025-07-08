
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_review_app/models/post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  Stream<List<Post>> getPosts({String? searchQuery}) {
    Query query = _postsCollection;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .where('hotelName', isGreaterThanOrEqualTo: searchQuery)
          .where('hotelName',
              isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .orderBy('hotelName', descending: false)
          .orderBy('timestamp', descending: true);
    } else {
      query = query.orderBy('timestamp', descending: true);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());
  }

  Future<void> addPost(Post post) {
    return _postsCollection.add(post.toMap());
  }

  Stream<List<Post>> getPostsForHotel(String osmId) {
    return _postsCollection
        .where('hotelOsmId', isEqualTo: osmId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());
  }

  Future<void> toggleLike(String postId, String userId) async {
    DocumentReference postRef = _postsCollection.doc(postId);
    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(postRef);
      if (!snapshot.exists) {
        throw Exception("Post does not exist!");
      }
      
      List<String> likes = List<String>.from(snapshot['likes'] ?? []);
      
      if (likes.contains(userId)) {
        transaction.update(postRef, {
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        transaction.update(postRef, {
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    }).catchError((error) {
      print("Failed to toggle like: $error");
    });
  }
}
