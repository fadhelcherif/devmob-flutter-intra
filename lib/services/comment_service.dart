import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a comment
  Future<void> createComment({
    required String postId,
    required String userId,
    required String userName,
    required String userImage,
    required String content,
  }) async {
    try {
      // Create comment document
      DocumentReference commentRef = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'postId': postId,
        'userId': userId,
        'userName': userName,
        'userImage': userImage,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update comment with its ID
      await commentRef.update({'id': commentRef.id});

      // Increment comments count on post
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      print('Comment created successfully');
    } catch (e) {
      print('Create comment error: $e');
      rethrow;
    }
  }

  // Get comments for a post
  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Decrement comments count on post
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(-1),
      });

      print('Comment deleted successfully');
    } catch (e) {
      print('Delete comment error: $e');
      rethrow;
    }
  }
}
