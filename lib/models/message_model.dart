import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String? chatId;
  final String? groupId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, bool>? readBy;

  MessageModel({
    required this.id,
    this.chatId,
    this.groupId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.readBy,
  });

  Map<String, dynamic> toMap() {
    return {
      if (chatId != null) 'chatId': chatId,
      if (groupId != null) 'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (readBy != null) 'readBy': readBy,
    };
  }

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      chatId: map['chatId'],
      groupId: map['groupId'],
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      readBy: map['readBy'] != null ? Map<String, bool>.from(map['readBy']) : null,
    );
  }
}
