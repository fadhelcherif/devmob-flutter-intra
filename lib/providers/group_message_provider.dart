import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class GroupMessageProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  final List<MessageModel> _messages = [];
  final bool _isLoading = false;
  String _error = '';
  bool _isSending = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isSending => _isSending;

  // Listen to group messages in real-time
  Stream<List<MessageModel>> listenToGroupMessages(String groupId) {
    return _chatService.getGroupMessages(groupId);
  }

  // Send a text message to group
  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    _isSending = true;
    _error = '';
    notifyListeners();

    try {
      await _chatService.sendGroupMessage(
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: content,
      );
    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // Send an image message to group
  Future<void> sendGroupImageMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String imageUrl,
  }) async {
    _isSending = true;
    _error = '';
    notifyListeners();

    try {
      await _chatService.sendGroupImageMessage(
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        imageUrl: imageUrl,
      );
    } catch (e) {
      _error = 'Failed to send image: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // Delete a message
  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
    required String currentUserId,
    required String messageSenderId,
  }) async {
    try {
      await _chatService.deleteGroupMessage(
        groupId: groupId,
        messageId: messageId,
        currentUserId: currentUserId,
        messageSenderId: messageSenderId,
      );
    } catch (e) {
      _error = 'Failed to delete message: $e';
      notifyListeners();
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String groupId,
    required String userId,
    required List<String> messageIds,
  }) async {
    try {
      if (messageIds.isNotEmpty) {
        await _chatService.markGroupMessagesAsRead(
          groupId: groupId,
          userId: userId,
          messageIds: messageIds,
        );
      }
    } catch (e) {
      // Silent fail for read receipt tracking
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
