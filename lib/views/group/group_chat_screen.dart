import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../models/group_model.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/group_service.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final GroupService _groupService = GroupService();

  UserModel? _currentUser;
  GroupModel? _groupData;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadGroupData();
  }

  Future<void> _loadCurrentUser() async {
    UserModel? user = await _authService.getUserData(
      _authService.currentUser!.uid,
    );
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadGroupData() async {
    GroupModel? group = await _groupService.getGroup(widget.groupId);
    if (!mounted) return;
    setState(() {
      _groupData = group;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;

    try {
      await _chatService.sendGroupMessage(
        groupId: widget.groupId,
        senderId: _currentUser!.uid,
        senderName: _currentUser!.name,
        senderImage:
            _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
        content: _messageController.text.trim(),
      );
      _messageController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendImage() async {
    if (_currentUser == null) return;

    XFile? image = await _storageService.pickImage();
    if (image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? imageUrl = await _storageService.uploadImageFile(
        image,
        'group_messages/${widget.groupId}',
      );

      if (mounted) {
        Navigator.pop(context);
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _chatService.sendGroupImageMessage(
          groupId: widget.groupId,
          senderId: _currentUser!.uid,
          senderName: _currentUser!.name,
          senderImage:
              _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    }
  }

  Future<void> _sendDocument() async {
    if (_currentUser == null) return;

    final picked = await _storageService.pickDocument();
    if (picked == null || picked.files.isEmpty) return;

    final file = picked.files.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final documentUrl = await _storageService.uploadDocument(
        file,
        'group_docs/${widget.groupId}',
      );

      if (mounted) {
        Navigator.pop(context);
      }

      if (documentUrl != null && documentUrl.isNotEmpty) {
        await _chatService.sendGroupDocumentMessage(
          groupId: widget.groupId,
          senderId: _currentUser!.uid,
          senderName: _currentUser!.name,
          senderImage:
              _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
          documentUrl: documentUrl,
          documentName: file.name,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading document: $e')));
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
              backgroundColor: theme.primaryColor,
              child: Text(
                (_groupData?.name.isNotEmpty ?? false)
                    ? _groupData!.name.substring(0, 1).toUpperCase()
                    : 'G',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _groupData?.name ?? 'Group',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_groupData?.members.length ?? 0} members',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getGroupMessages(widget.groupId),
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
                  IconButton(
                    onPressed: _sendImage,
                    icon: Icon(Icons.image, color: theme.primaryColor),
                  ),
                  IconButton(
                    onPressed: _sendDocument,
                    icon: Icon(Icons.attach_file, color: theme.primaryColor),
                  ),
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(message.id)
          .get(),
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
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                DecoratedBox(
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
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
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
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                  child: Text(
                    'Sent by ${message.senderName}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
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
