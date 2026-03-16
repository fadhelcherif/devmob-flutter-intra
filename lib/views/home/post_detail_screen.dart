import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../widgets/comment_box.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  late bool _isLikedByCurrentUser;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    final String? currentUserId = _authService.currentUser?.uid;
    _isLikedByCurrentUser =
        currentUserId != null && widget.post.likes.contains(currentUserId);
    _likesCount = widget.post.likes.length;
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
        title: const Text(
          'Post',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(widget.post.userImage),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _getTimeAgo(widget.post.createdAt),
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

                  const SizedBox(height: 12),

                  // Post text
                  Text(
                    widget.post.content,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),

                  // Post image
                  if (widget.post.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Like and comment counts
                  Row(
                    children: [
                      Icon(Icons.thumb_up, size: 16, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '$_likesCount Likes',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.commentsCount} comments',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        _isLikedByCurrentUser
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        'Like',
                        color: _isLikedByCurrentUser
                            ? theme.primaryColor
                            : colorScheme.onSurfaceVariant,
                        onTap: () => _likePost(),
                      ),
                      _buildActionButton(
                        Icons.chat_bubble_outline,
                        'Comment',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Comments section header
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.surface,
              child: Text(
                'Comments',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // Comments section
            Container(
              color: colorScheme.surface,
              child: CommentBox(postId: widget.post.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: resolvedColor,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: resolvedColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _likePost() async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId != null) {
        setState(() {
          if (_isLikedByCurrentUser) {
            _likesCount--;
          } else {
            _likesCount++;
          }
          _isLikedByCurrentUser = !_isLikedByCurrentUser;
        });

        await _postService.likePost(widget.post.id, userId);
      }
    } catch (e) {
      setState(() {
        if (_isLikedByCurrentUser) {
          _likesCount--;
        } else {
          _likesCount++;
        }
        _isLikedByCurrentUser = !_isLikedByCurrentUser;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
