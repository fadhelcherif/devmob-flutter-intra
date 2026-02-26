// Post model
import 'package:cloud_firestore/cloud_firestore.dart';



// Add to fromMap

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
  final String? documentUrl;
  final String? documentName;
  

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
    this.documentUrl,
    this.documentName,

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
      'documentUrl': documentUrl,
      'documentName': documentName,
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
      documentUrl: map['documentUrl'],
documentName: map['documentName'],
    );
  }
}
