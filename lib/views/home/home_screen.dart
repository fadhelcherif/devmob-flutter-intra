import 'package:flutter/material.dart';
import 'post_creation.dart';
import 'discover.dart';
import '../group/group_screen.dart';
import '../chat/chat_list.dart';
import '../profile/profile_menu_screen.dart';
import 'notifications.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const ProfileMenuScreen(),
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
      body: ListView(
        children: [
          // First Post
          _buildPost(
            userName: 'Akash Pandey',
            userTitle: 'Yoga Enthusiast and Meditation...',
            timeAgo: '2h',
            userImage: 'https://i.pravatar.cc/150?img=11',
            postText: 'Did you know that the choices we make in the kitchen play a significant role in our overall health? 🌱 Join me on a journ...',
            postImage: 'https://picsum.photos/400/300?random=1',
            likes: 53,
            comments: 8,
          ),
          
          // Second Post
          _buildPost(
            userName: 'Mohd. Farooq',
            userTitle: 'Marketing Specialist & Fitness...',
            timeAgo: '',
            userImage: 'https://i.pravatar.cc/150?img=12',
            postText: "In today's fast-paced world, stress has become a common companion. But fear not!",
            postImage: null,
            likes: 0,
            comments: 0,
          ),
        ],
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
        // Home - stay on current page
        break;
      case 1:
        case 1:
        // My Groups
        Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const GroupsScreen()),
  );
  break;
        break;
      case 2:
        // Discover
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DiscoverScreen()),
        );
        break;
      case 3:
  // Notifications
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
      label: ' Groups',
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

  Widget _buildPost({
    required String userName,
    required String userTitle,
    required String timeAgo,
    required String userImage,
    required String postText,
    String? postImage,
    required int likes,
    required int comments,
  }) {
    return Container(
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
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(userImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$userTitle · $timeAgo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Post text
          Text(
            postText,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          
          // Post image
          if (postImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                postImage,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Likes and comments count
          Row(
            children: [
              Icon(Icons.thumb_up, size: 16, color: const Color(0xFF2196F3)),
              const SizedBox(width: 4),
              Text(
                '$likes Likes',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$comments comments',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.thumb_up_outlined, 'Like'),
              _buildActionButton(Icons.thumb_down_outlined, 'Dislike'),
              _buildActionButton(Icons.chat_bubble_outline, 'Comment'),
              _buildActionButton(Icons.share_outlined, 'Share'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
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
}