import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();

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

  Stream<List<MessageModel>> listenToGroupMessages(String groupId) {
    return _chatService.getGroupMessages(groupId);
  }

  Future<void> ensureDirectChatExists({
    required String userId,
    required String otherUserId,
  }) {
    return _chatService.ensureDirectChatExists(
      userId: userId,
      otherUserId: otherUserId,
    );
  }

  String getChatId(String userId1, String userId2) {
    return _chatService.getChatId(userId1, userId2);
  }

  Future<XFile?> pickImage() {
    return _storageService.pickImage();
  }

  Future<FilePickerResult?> pickDocument() {
    return _storageService.pickDocument();
  }

  Future<String?> uploadImageFile(XFile imageFile, String folder) {
    return _storageService.uploadImageFile(imageFile, folder);
  }

  Future<String?> uploadDocument(PlatformFile file, String folder) {
    return _storageService.uploadDocument(file, folder);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDirectMessageMetadata({
    required String userId1,
    required String userId2,
    required String messageId,
  }) {
    final chatId = _chatService.getChatId(userId1, userId2);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getGroupMessageMetadata({
    required String groupId,
    required String messageId,
  }) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .get();
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String content,
  }) {
    return _chatService.sendGroupMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      content: content,
    );
  }

  Future<void> sendGroupImageMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String imageUrl,
  }) {
    return _chatService.sendGroupImageMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      imageUrl: imageUrl,
    );
  }

  Future<void> sendGroupDocumentMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String documentUrl,
    required String documentName,
  }) {
    return _chatService.sendGroupDocumentMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      documentUrl: documentUrl,
      documentName: documentName,
    );
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