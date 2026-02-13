// ChatList screen
import 'package:flutter/material.dart';
import 'chat_detail.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Alex Turner',
      'message': 'You: Great! I\'ll see you then. 👋',
      'time': '9:12pm',
      'image': 'https://i.pravatar.cc/150?img=11',
      'unread': 0,
    },
    {
      'name': 'Emma Watson',
      'message': 'Of course! This is a HIIT class on...',
      'time': '9:30pm',
      'image': 'https://i.pravatar.cc/150?img=5',
      'unread': 2,
    },
    {
      'name': 'Rahul Vivek',
      'message': 'Nice choice! I\'m more into cla...',
      'time': '9:25pm',
      'image': 'https://i.pravatar.cc/150?img=3',
      'unread': 1,
    },
    {
      'name': 'Priya Wankhede',
      'message': 'Awesome! See you on Sunday...',
      'time': '9:10pm',
      'image': 'https://i.pravatar.cc/150?img=9',
      'unread': 1,
    },
    {
      'name': 'Akshay Khanna',
      'message': 'You: Definitely! Count me in. L...',
      'time': '8:10pm',
      'image': 'https://i.pravatar.cc/150?img=12',
      'unread': 0,
    },
    {
      'name': 'Maya Sharma',
      'message': 'Wonderful! See you on Wedne...',
      'time': '8:02pm',
      'image': 'https://i.pravatar.cc/150?img=24',
      'unread': 0,
    },
    {
      'name': 'Chris Dickens',
      'message': 'Nice! I\'m diving into UX resear...',
      'time': '8:15pm',
      'image': 'https://i.pravatar.cc/150?img=13',
      'unread': 0,
    },
    {
      'name': 'Ananya Pandey',
      'message': 'You: Awesome! If you have an...',
      'time': '9:10pm',
      'image': 'https://i.pravatar.cc/150?img=8',
      'unread': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // Chats list
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatTile(chat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(chat['image']),
      ),
      title: Text(
        chat['name'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        chat['message'],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['time'],
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          if (chat['unread'] > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat['unread'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatDetailScreen(
        userName: chat['name'],
        userImage: chat['image'],
      ),
    ),
  );
},
    );
  }
}