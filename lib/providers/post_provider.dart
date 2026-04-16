import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  List<PostModel> _posts = [];
  bool _isLoading = false;
  String _error = '';

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String get error => _error;

  Stream<List<PostModel>> watchMainFeedPosts(String currentUserId) {
    return _postService.getMainFeedPosts(currentUserId);
  }

  Stream<List<PostModel>> watchUserPosts(String userId) {
    return _postService.getUserPosts(userId);
  }

  Stream<List<PostModel>> watchGroupPosts(String groupId) {
    return _postService.getGroupPosts(groupId);
  }

  Future<void> refreshMainFeedPosts(String currentUserId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _posts = await _postService.getMainFeedPosts(currentUserId).first;
    } catch (e) {
      _error = 'Failed to load feed posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserPosts(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _posts = await _postService.getUserPosts(userId).first;
    } catch (e) {
      _error = 'Failed to load user posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _postService.createPost(
        userId: userId,
        userName: userName,
        userImage: userImage,
        content: content,
        groupId: groupId,
        groupName: groupName,
        imageUrl: imageUrl,
        documentUrl: documentUrl,
        documentName: documentName,
      );
    } catch (e) {
      _error = 'Failed to create post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editPost(String postId, String newContent) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _postService.editPost(postId, newContent);
    } catch (e) {
      _error = 'Failed to edit post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _postService.deletePost(postId);
      _posts = _posts.where((post) => post.id != postId).toList();
    } catch (e) {
      _error = 'Failed to delete post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    _error = '';
    notifyListeners();

    try {
      await _postService.likePost(postId, userId);
    } catch (e) {
      _error = 'Failed to update like: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}