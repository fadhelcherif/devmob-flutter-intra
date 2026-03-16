import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../models/group_model.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/group_service.dart';
import '../../providers/group_message_provider.dart';
import 'package:intl/intl.dart';

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
  bool _isLoadingImage = false;
  final ScrollController _scrollController = ScrollController();

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
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadGroupData() async {
    GroupModel? group = await _groupService.getGroup(widget.groupId);
    setState(() {
      _groupData = group;
    });
  }

  Future<void> _pickAndSendImage() async {
    setState(() => _isLoadingImage = true);

    try {
      XFile? image = await _storageService.pickImageWithSource(
        ImageSource.gallery,
      );

      if (image != null && _currentUser != null) {
        String? imageUrl = await _storageService.uploadImageFile(
          image,
          'group_messages/${widget.groupId}',
        );

        if ((imageUrl?.isNotEmpty ?? false) && mounted) {
          context.read<GroupMessageProvider>().sendGroupImageMessage(
            groupId: widget.groupId,
            senderId: _currentUser!.uid,
            senderName: _currentUser!.name,
            senderImage: _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
            imageUrl: imageUrl!,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingImage = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) {
      return;
    }

    String message = _messageController.text.trim();
    _messageController.clear();

    context.read<GroupMessageProvider>().sendGroupMessage(
      groupId: widget.groupId,
      senderId: _currentUser!.uid,
      senderName: _currentUser!.name,
      senderImage: _currentUser!.profileImageUrl ?? 'https://i.pravatar.cc/150',
      content: message,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }

  void _showMessageOptions(MessageModel message) {
    final theme = Theme.of(context);
    final canDelete = message.senderId == _currentUser?.uid;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (canDelete)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<GroupMessageProvider>().deleteMessage(
                    groupId: widget.groupId,
                    messageId: message.id,
                    currentUserId: _currentUser!.uid,
                    messageSenderId: message.senderId,
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.copy, color: theme.primaryColor),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy to clipboard
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: _groupData != null
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      _groupData!.name.substring(0, 1).toUpperCase(),
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
                          _groupData!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_groupData!.members.length} members',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getGroupMessages(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUser?.uid;

                    return GestureDetector(
                      onLongPress: () => _showMessageOptions(message),
                      child: _buildMessageBubble(
                        message,
                        isMe,
                        theme,
                        colorScheme,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input field
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
                  if (!_isLoadingImage)
                    IconButton(
                      onPressed: _pickAndSendImage,
                      icon: Icon(
                        Icons.image,
                        color: theme.primaryColor,
                      ),
                    )
                  else
                    IconButton(
                      onPressed: null,
                      icon: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<GroupMessageProvider>(
                    builder: (context, provider, _) {
                      return CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        child: IconButton(
                          onPressed: provider.isSending ? null : _sendMessage,
                          icon: provider.isSending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.send,
                                  color: colorScheme.onPrimary,
                                  size: 20,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isImage = message.content == '📷 Image';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(message.senderImage),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.primaryColor
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.content, // Using content as placeholder
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey,
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                        )
                      : SelectableText(
                          message.content,
                          style: TextStyle(
                            color: isMe
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
