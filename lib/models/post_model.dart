// Post model
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.content,
    this.imageUrl,
    this.likes = const [],
    this.commentsCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}