import 'package:flutter/material.dart';
import 'group_screen.dart';
import 'mygroup.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final List<Map<String, dynamic>> groups = [
    {
      'name': 'Dev mobile Group',
      'type': 'Public',
      'members': 82,
      'host': 'Anamika Jain',
      'hostImage': 'https://i.pravatar.cc/150?img=5',
      'isJoined': false,
    },
    {
      'name': 'C# Discussion group',
      'type': 'Public',
      'members': 24,
      'host': 'Max Albino',
      'hostImage': 'https://i.pravatar.cc/150?img=3',
      'isJoined': false,
    },
    {
      'name': 'C# Discussion group',
      'type': 'Private',
      'members': 24,
      'host': 'Max Albino',
      'hostImage': 'https://i.pravatar.cc/150?img=3',
      'isJoined': false,
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
          'Join group',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.group_add, color: Colors.black),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildGroupCard(group);
        },
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final bool isPublic = group['type'] == 'Public';
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GroupDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type and menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group['type'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Group name
            Text(
              group['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Members avatars
            Row(
              children: [
                _buildMemberAvatar('https://i.pravatar.cc/150?img=1'),
                _buildMemberAvatar('https://i.pravatar.cc/150?img=2'),
                const SizedBox(width: 8),
                Text(
                  'and ${group['members']} others are members',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Host
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(group['hostImage']),
                ),
                const SizedBox(width: 8),
                Text(
                  group['host'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Host',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Join button
            SizedBox(
              width: 80,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    group['isJoined'] = !group['isJoined'];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: group['isJoined'] ? Colors.grey : const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  group['isJoined'] ? 'Joined' : 'Join',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}