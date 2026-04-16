import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<MessageModel> _messages = [];
  List<Map<String, dynamic>> _userChats = [];
  List<Map<String, dynamic>> _userGroupChats = [];
  bool _isLoading = false;
  bool _isSending = false;
  String _error = '';

  List<MessageModel> get messages => _messages;
  List<Map<String, dynamic>> get userChats => _userChats;
  List<Map<String, dynamic>> get userGroupChats => _userGroupChats;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String get error => _error;

  Stream<List<MessageModel>> listenToMessages(String userId1, String userId2) {
    return _chatService.getMessages(userId1, userId2);
  }

  Stream<List<Map<String, dynamic>>> listenToUserChats(String userId) {
    return _chatService.getUserChats(userId);
  }

  Stream<List<Map<String, dynamic>>> listenToUserGroupChats(String userId) {
    return _chatService.getUserGroupChats(userId);
  }

  Future<void> refreshMessages(String userId1, String userId2) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _messages = await _chatService.getMessages(userId1, userId2).first;
    } catch (e) {
      _error = 'Failed to load messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserChats(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _userChats = await _chatService.getUserChats(userId).first;
    } catch (e) {
      _error = 'Failed to load chats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserGroupChats(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _userGroupChats = await _chatService.getUserGroupChats(userId).first;
    } catch (e) {
      _error = 'Failed to load group chats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    _isSending = true;
    _error = '';
    notifyListeners();

    try {
      await _chatService.sendMessage(
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> sendImageMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String imageUrl,
  }) async {
    _isSending = true;
    _error = '';
    notifyListeners();

    try {
      await _chatService.sendImageMessage(
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        receiverId: receiverId,
        imageUrl: imageUrl,
      );
    } catch (e) {
      _error = 'Failed to send image: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> sendDocumentMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String documentUrl,
    required String documentName,
  }) async {
    _isSending = true;
    _error = '';
    notifyListeners();

    try {
      await _chatService.sendDocumentMessage(
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        receiverId: receiverId,
        documentUrl: documentUrl,
        documentName: documentName,
      );
    } catch (e) {
      _error = 'Failed to send document: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}