// PostService
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('posts');

  // Create new post
  Future<void> createPost({
    required String userId,
    required String userName,
    required String userImage,
    required String content,
    String? imageUrl,
  }) async {
    try {
      DocumentReference docRef = _postsCollection.doc();
      
      PostModel post = PostModel(
        id: docRef.id,
        userId: userId,
        userName: userName,
        userImage: userImage,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      
      await docRef.set(post.toMap());
    } catch (e) {
      print('Create post error: $e');
      throw e;
    }
  }

  // Get all posts
  Stream<List<PostModel>> getPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  // Get posts by specific user
Stream<List<PostModel>> getUserPosts(String userId) {
  return _postsCollection
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return PostModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  });
}

  // Update user name in all their posts
Future<void> updateUserNameInPosts(String userId, String newName) async {
  try {
    // Get all posts by this user
    QuerySnapshot posts = await _postsCollection
        .where('userId', isEqualTo: userId)
        .get();
    
    // Update each post
    for (var doc in posts.docs) {
      await doc.reference.update({'userName': newName});
    }
    
    print('Updated ${posts.docs.length} posts with new name');
  } catch (e) {
    print('Update posts error: $e');
    throw e;
  }
}
// Edit post
Future<void> editPost(String postId, String newContent) async {
  try {
    await _postsCollection.doc(postId).update({
      'content': newContent,
      'editedAt': Timestamp.now(),
    });
  } catch (e) {
    print('Edit post error: $e');
    throw e;
  }
}

// Delete post
Future<void> deletePost(String postId) async {
  try {
    await _postsCollection.doc(postId).delete();
  } catch (e) {
    print('Delete post error: $e');
    throw e;
  }
}

  // Like post
  Future<void> likePost(String postId, String userId) async {
    try {
      DocumentReference postRef = _postsCollection.doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(postRef);
        
        if (!snapshot.exists) {
          throw Exception('Post does not exist');
        }
        
        List<String> likes = List<String>.from(snapshot['likes'] ?? []);
        
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }
        
        transaction.update(postRef, {'likes': likes});
      });
    } catch (e) {
      print('Like post error: $e');
      throw e;
    }
  }
}