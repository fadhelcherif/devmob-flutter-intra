import 'package:flutter/material.dart';
import 'post_creation.dart';
import 'discover.dart';
import 'post_detail_screen.dart';
import '../group/group_screen.dart';
import '../chat/chat_list.dart';
import '../profile/profile_menu_screen.dart';
import 'notifications.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../services/auth_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
        ),
        title: const Text(
          'Entreprise_Name',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagesScreen()),
              );
            },
            icon: const Icon(Icons.people_outline, color: Colors.black),
          ),
        ],
      ),
      drawer: const ProfileMenuScreen(),
      body: StreamBuilder<List<PostModel>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Create one!'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPost(post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupsScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiscoverScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'My Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _buildPost(PostModel post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(post.userImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _getTimeAgo(post.createdAt),
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
          
          Text(
            post.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(Icons.thumb_up, size: 16, color: const Color(0xFF2196F3)),
              const SizedBox(width: 4),
              Text(
                '${post.likes.length} Likes',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${post.commentsCount} comments',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.thumb_up_outlined, 
                'Like',
                onTap: () => _likePost(post),
              ),
              _buildActionButton(Icons.thumb_down_outlined, 'Dislike'),
              _buildActionButton(
                Icons.chat_bubble_outline, 
                'Comment',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  );
                },
              ),
              _buildActionButton(Icons.share_outlined, 'Share'),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _likePost(PostModel post) async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _postService.likePost(post.id, userId);
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