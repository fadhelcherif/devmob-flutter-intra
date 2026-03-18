// PostService
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsCollection = FirebaseFirestore.instance
      .collection('posts');
  final CollectionReference _groupsCollection = FirebaseFirestore.instance
      .collection('groups');

  // Create new post
    Future<void> createPost({
      required String userId,
      required String userName,
      required String userImage,
      required String content,
      String? groupId,
      String? groupName,
      String? imageUrl,
      String? documentUrl,
      String? documentName,
    }) async {
    try {
      DocumentReference docRef = _postsCollection.doc();

      PostModel post = PostModel(
        id: docRef.id,
        userId: userId,
        userName: userName,
        userImage: userImage,
        groupId: groupId,
        groupName: groupName,
        content: content,
        imageUrl: imageUrl,
        documentUrl: documentUrl,
        documentName: documentName,
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
            return PostModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  // Get posts visible in the main feed based on group privacy.
  // Public group posts are visible to everyone.
  // Private group posts are visible only to group members.
  Stream<List<PostModel>> getMainFeedPosts(String currentUserId) {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final allPosts = snapshot.docs
              .map(
                (doc) => PostModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

          final groupIds = allPosts
              .map((post) => post.groupId)
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList();

          if (groupIds.isEmpty) {
            return allPosts;
          }

          final groupsById = await _getGroupsByIds(groupIds);

          return allPosts.where((post) {
            final groupId = post.groupId;
            if (groupId == null || groupId.isEmpty) {
              return true;
            }

            final groupData = groupsById[groupId];
            if (groupData == null) {
              return false;
            }

            final isPublic = groupData['isPublic'] == true;
            if (isPublic) {
              return true;
            }

            final members = List<String>.from(groupData['members'] ?? []);
            return members.contains(currentUserId);
          }).toList();
        });
  }

  Future<Map<String, Map<String, dynamic>>> _getGroupsByIds(
    List<String> groupIds,
  ) async {
    final Map<String, Map<String, dynamic>> groupsById = {};

    // Firestore whereIn accepts up to 10 document IDs per query.
    for (int i = 0; i < groupIds.length; i += 10) {
      final chunk = groupIds.sublist(
        i,
        i + 10 > groupIds.length ? groupIds.length : i + 10,
      );

      final snapshot = await _groupsCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        groupsById[doc.id] = doc.data() as Map<String, dynamic>;
      }
    }

    return groupsById;
  }

  // Get posts by specific user
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  Stream<List<PostModel>> getGroupPosts(String groupId) {
    return _postsCollection
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
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
