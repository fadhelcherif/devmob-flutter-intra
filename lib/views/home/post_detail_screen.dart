import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../widgets/comment_box.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
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
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
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
                                color: Colors.grey[600],
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
                      Icon(Icons.thumb_up, size: 16, color: const Color(0xFF2196F3)),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.likes.length} Likes',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.commentsCount} comments',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        Icons.thumb_up_outlined,
                        'Like',
                        onTap: () => _likePost(),
                      ),
                      _buildActionButton(Icons.thumb_down_outlined, 'Dislike'),
                      _buildActionButton(Icons.share_outlined, 'Share'),
                    ],
                  ),
                ],
              ),
            ),

            // Comments section header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
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
              color: Colors.white,
              child: CommentBox(postId: widget.post.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _likePost() async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _postService.likePost(widget.post.id, userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
