import 'package:flutter/material.dart';
import '../chat/chat_detail.dart';
import 'user_profile.dart';

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen> {
  final List<Map<String, dynamic>> connections = [
    {
      'name': 'Alex Turner',
      'title': 'Product Designer at Google',
      'image': 'https://i.pravatar.cc/150?img=11',
      'isOnline': true,
    },
    {
      'name': 'Emma Watson',
      'title': 'Software Engineer at Meta',
      'image': 'https://i.pravatar.cc/150?img=5',
      'isOnline': false,
    },
    {
      'name': 'Rahul Vivek',
      'title': 'Marketing Manager at Amazon',
      'image': 'https://i.pravatar.cc/150?img=3',
      'isOnline': true,
    },
    {
      'name': 'Priya Wankhede',
      'title': 'UX Researcher at Microsoft',
      'image': 'https://i.pravatar.cc/150?img=9',
      'isOnline': false,
    },
    {
      'name': 'Akshay Khanna',
      'title': 'Data Scientist at Netflix',
      'image': 'https://i.pravatar.cc/150?img=12',
      'isOnline': true,
    },
    {
      'name': 'Maya Sharma',
      'title': 'Product Manager at Apple',
      'image': 'https://i.pravatar.cc/150?img=24',
      'isOnline': false,
    },
    {
      'name': 'Chris Dickens',
      'title': 'Frontend Developer at Spotify',
      'image': 'https://i.pravatar.cc/150?img=13',
      'isOnline': true,
    },
    {
      'name': 'Ananya Pandey',
      'title': 'HR Manager at Tesla',
      'image': 'https://i.pravatar.cc/150?img=8',
      'isOnline': false,
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
          'My Connections',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_add, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search connections',
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
          
          // Connections count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${connections.length} connections',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Connections list
          Expanded(
            child: ListView.builder(
              itemCount: connections.length,
              itemBuilder: (context, index) {
                final connection = connections[index];
                return _buildConnectionTile(connection);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTile(Map<String, dynamic> connection) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(connection['image']),
          ),
          if (connection['isOnline'])
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        connection['name'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        connection['title'],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    userName: connection['name'],
                    userImage: connection['image'],
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.message,
              color: Color(0xFF2196F3),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserProfileScreen(
      ),     
      ),
    );
      }
    );
  }
}