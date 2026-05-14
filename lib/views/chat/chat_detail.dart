import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final String receiverId;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.userImage,
    required this.receiverId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUserId = authProvider.currentUserId;
    if (currentUserId == null) return;

    UserModel? user = await authProvider.getUserById(currentUserId);
    if (user != null) {
      await chatProvider.ensureDirectChatExists(
        userId: user.uid,
        otherUserId: widget.receiverId,
      );
    }
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.sendMessage(
        senderId: _currentUser!.uid,
        senderName: _currentUser!.name,
        senderImage:
            _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
        receiverId: widget.receiverId,
        content: _messageController.text.trim(),
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendImage() async {
    if (_currentUser == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    XFile? image = await chatProvider.pickImage();
    if (image == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? imageUrl = await chatProvider.uploadImageFile(
        image,
        'chat_images',
      );

      Navigator.pop(context); // Close loading

      if (imageUrl != null) {
        await chatProvider.sendImageMessage(
          senderId: _currentUser!.uid,
          senderName: _currentUser!.name,
          senderImage:
              _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
          receiverId: widget.receiverId,
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    }
  }

  Future<void> _sendDocument() async {
    if (_currentUser == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final picked = await chatProvider.pickDocument();
    if (picked == null || picked.files.isEmpty) return;

    final file = picked.files.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final documentUrl = await chatProvider.uploadDocument(file, 'chat_docs');

      if (mounted) {
        Navigator.pop(context);
      }

      if (documentUrl != null && documentUrl.isNotEmpty) {
        await chatProvider.sendDocumentMessage(
          senderId: _currentUser!.uid,
          senderName: _currentUser!.name,
          senderImage:
              _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
          receiverId: widget.receiverId,
          documentUrl: documentUrl,
          documentName: file.name,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading document: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.userImage),
            ),
            const SizedBox(width: 12),
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: Provider.of<ChatProvider>(
                context,
                listen: false,
              ).listenToMessages(
                _currentUser!.uid,
                widget.receiverId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start chatting!'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUser!.uid;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          // Input field - SIMPLIFIED
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Image button
                  IconButton(
                    onPressed: _sendImage,
                    icon: Icon(Icons.image, color: theme.primaryColor),
                  ),
                  IconButton(
                    onPressed: _sendDocument,
                    icon: Icon(Icons.attach_file, color: theme.primaryColor),
                  ),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  // Send button
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: theme.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    // Check if message is an image by checking if it has imageUrl in Firestore
    // We need to get the raw data to check for imageUrl
    return FutureBuilder<DocumentSnapshot>(
      future: Provider.of<ChatProvider>(
        context,
        listen: false,
      ).getDirectMessageMetadata(
        userId1: _currentUser!.uid,
        userId2: widget.receiverId,
        messageId: message.id,
      ),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        bool isImage = false;
        bool isDocument = false;
        String? imageUrl;
        String? documentUrl;
        String? documentName;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          isImage = data?['isImage'] == true;
          isDocument = data?['isDocument'] == true;
          imageUrl = data?['imageUrl'];
          documentUrl = data?['documentUrl'];
          documentName = data?['documentName'];
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe ? theme.primaryColor : colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
                child: isImage && imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 100,
                          padding: const EdgeInsets.all(16),
                          child: const Text('Failed to load image'),
                        );
                      },
                    )
                  : isDocument && documentUrl != null
                  ? InkWell(
                      onTap: () async {
                        final uri = Uri.tryParse(documentUrl!);
                        if (uri != null) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              color: isMe
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                documentName ?? 'Open document',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isMe
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: isMe
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
