import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique chat ID from two user IDs (sorted alphabetically)
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  // Ensure a direct chat document exists before reading its messages.
  Future<void> ensureDirectChatExists({
    required String userId,
    required String otherUserId,
  }) async {
    final chatId = getChatId(userId, otherUserId);
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [userId, otherUserId],
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // Send message
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String content,
  }) async {
    try {
      String chatId = getChatId(senderId, receiverId);

      DocumentReference docRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      MessageModel message = MessageModel(
        id: docRef.id,
        chatId: chatId,
        groupId: null,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: content,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': content,
        'lastMessageTime': Timestamp.now(),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));

      await docRef.set(message.toMap());
    } catch (e) {
      print('Send message error: $e');
      rethrow;
    }
  }

  // Send image message
  Future<void> sendImageMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String imageUrl,
  }) async {
    try {
      String chatId = getChatId(senderId, receiverId);

      DocumentReference docRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      MessageModel message = MessageModel(
        id: docRef.id,
        chatId: chatId,
        groupId: null,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: '📷 Image', // Placeholder text
        timestamp: DateTime.now(),
      );

      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': '📷 Image',
        'lastMessageTime': Timestamp.now(),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));

      await docRef.set({
        ...message.toMap(),
        'imageUrl': imageUrl,
        'isImage': true,
      });
    } catch (e) {
      print('Send image message error: $e');
      rethrow;
    }
  }

  // Send document message
  Future<void> sendDocumentMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String documentUrl,
    required String documentName,
  }) async {
    try {
      String chatId = getChatId(senderId, receiverId);

      DocumentReference docRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      MessageModel message = MessageModel(
        id: docRef.id,
        chatId: chatId,
        groupId: null,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: '📎 $documentName',
        timestamp: DateTime.now(),
      );

      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': '📎 $documentName',
        'lastMessageTime': Timestamp.now(),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));

      await docRef.set({
        ...message.toMap(),
        'documentUrl': documentUrl,
        'documentName': documentName,
        'isDocument': true,
      });
    } catch (e) {
      print('Send document message error: $e');
      rethrow;
    }
  }

  // Get messages between two users
  Stream<List<MessageModel>> getMessages(String userId1, String userId2) {
    String chatId = getChatId(userId1, userId2);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // Get user's chat list (for messages screen)
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data();
                List<dynamic> participants = data['participants'] ?? [];
                if (participants.length < 2 || !participants.contains(userId)) {
                  return null;
                }

                // Get the other user's ID
                String otherUserId = participants.firstWhere(
                  (id) => id != userId,
                  orElse: () => '',
                );
                if (otherUserId.isEmpty) {
                  return null;
                }

                return {
                  'chatId': doc.id,
                  'otherUserId': otherUserId,
                  'lastMessage': data['lastMessage'] ?? '',
                  'lastMessageTime': data['lastMessageTime'],
                };
              })
              .whereType<Map<String, dynamic>>()
              .toList();
        });
  }

  // ==================== GROUP MESSAGING LOGIC ====================

  // Send message to group
  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String content,
  }) async {
    try {
      // Create message in: groups/{groupId}/messages/{messageId}
      DocumentReference docRef = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc();

      MessageModel message = MessageModel(
        id: docRef.id,
        chatId: null,
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: content,
        timestamp: DateTime.now(),
      );

      // Update group's last message
      await _firestore.collection('groups').doc(groupId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': senderName,
      });

      // Save message
      await docRef.set(message.toMap());
    } catch (e) {
      print('Send group message error: $e');
      rethrow;
    }
  }

  // Get group messages (real-time stream)
  Stream<List<MessageModel>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // Get paginated group messages (for loading older messages)
  Future<List<MessageModel>> getGroupMessagesPaginated(
    String groupId, {
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Get paginated messages error: $e');
      rethrow;
    }
  }

  // Send image message to group
  Future<void> sendGroupImageMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String imageUrl,
  }) async {
    try {
      DocumentReference docRef = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc();

      await _firestore.collection('groups').doc(groupId).update({
        'lastMessage': '📷 Image',
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': senderName,
      });

      await docRef.set({
        'groupId': groupId,
        'senderId': senderId,
        'senderName': senderName,
        'senderImage': senderImage,
        'content': '📷 Image',
        'timestamp': Timestamp.now(),
        'imageUrl': imageUrl,
        'isImage': true,
      });
    } catch (e) {
      print('Send group image error: $e');
      rethrow;
    }
  }

  // Send document message to group
  Future<void> sendGroupDocumentMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String documentUrl,
    required String documentName,
  }) async {
    try {
      DocumentReference docRef = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc();

      await _firestore.collection('groups').doc(groupId).update({
        'lastMessage': '📎 $documentName',
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': senderName,
      });

      await docRef.set({
        'groupId': groupId,
        'senderId': senderId,
        'senderName': senderName,
        'senderImage': senderImage,
        'content': '📎 $documentName',
        'timestamp': Timestamp.now(),
        'documentUrl': documentUrl,
        'documentName': documentName,
        'isDocument': true,
      });
    } catch (e) {
      print('Send group document error: $e');
      rethrow;
    }
  }

  // Delete group message (only sender can delete)
  Future<void> deleteGroupMessage({
    required String groupId,
    required String messageId,
    required String currentUserId,
    required String messageSenderId,
  }) async {
    try {
      // Verify current user is sender
      if (currentUserId != messageSenderId) {
        throw Exception('Only message sender can delete');
      }

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Delete message error: $e');
      rethrow;
    }
  }

  // Mark messages as read by a user
  Future<void> markGroupMessagesAsRead({
    required String groupId,
    required String userId,
    required List<String> messageIds,
  }) async {
    try {
      // Batch write for efficiency
      WriteBatch batch = _firestore.batch();

      for (String messageId in messageIds) {
        DocumentReference ref = _firestore
            .collection('groups')
            .doc(groupId)
            .collection('messages')
            .doc(messageId);

        batch.update(ref, {
          'readBy.$userId': true,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Mark as read error: $e');
      rethrow;
    }
  }

  // Get user's group chats (for messages screen)
  Stream<List<Map<String, dynamic>>> getUserGroupChats(String userId) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            return {
              'groupId': doc.id,
              'groupName': data['name'] ?? '',
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageSender': data['lastMessageSender'] ?? '',
              'lastMessageTime': data['lastMessageTime'],
              'members': List<String>.from(data['members'] ?? []),
            };
          }).toList();
        });
  }
}
