import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique chat ID from two user IDs (sorted alphabetically)
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2]..sort();
    return ids.join('_');
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
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: content,
        timestamp: DateTime.now(),
      );

      await docRef.set(message.toMap());

      // Update last message in chat document
      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': content,
        'lastMessageTime': Timestamp.now(),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));

    } catch (e) {
      print('Send message error: $e');
      throw e;
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
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      content: '📷 Image', // Placeholder text
      timestamp: DateTime.now(),
    );

    // Add imageUrl to a separate field
    await docRef.set({
      ...message.toMap(),
      'imageUrl': imageUrl,
      'isImage': true,
    });

    // Update last message
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': '📷 Image',
      'lastMessageTime': Timestamp.now(),
      'participants': [senderId, receiverId],
    }, SetOptions(merge: true));

  } catch (e) {
    print('Send image message error: $e');
    throw e;
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
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> participants = data['participants'] ?? [];
        // Get the other user's ID
        String otherUserId = participants.firstWhere((id) => id != userId, orElse: () => '');
        
        return {
          'chatId': doc.id,
          'otherUserId': otherUserId,
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': data['lastMessageTime'],
        };
      }).toList();
    });
  }
}