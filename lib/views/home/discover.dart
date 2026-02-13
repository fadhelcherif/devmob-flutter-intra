import 'package:flutter/material.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> members = [
    {
      'name': 'Janni Purav',
      'title': 'Digital Marketing Specialist | SEO Strategist | Driving Online Visibility and...',
      'image': 'https://i.pravatar.cc/150?img=1',
      'isVerified': false,
    },
    {
      'name': 'Neeti Mohan',
      'title': 'Educational Psychologist | Student Success Advocate | Enriching Learning...',
      'image': 'https://i.pravatar.cc/150?img=5',
      'isVerified': false,
    },
    {
      'name': 'Akash Pandey',
      'title': 'Digital Marketing Specialist | SEO Strategist | Driving Online Visibility and...',
      'image': 'https://i.pravatar.cc/150?img=11',
      'isVerified': true,
    },
    {
      'name': 'Arvind Mishra',
      'title': 'Software Engineer | AI Enthusiast | Transforming Ideas into Impact...',
      'image': 'https://i.pravatar.cc/150?img=3',
      'isVerified': false,
    },
    {
      'name': 'Akshita Sharma',
      'title': 'Passionate Environmental Scientist | Sustainability Advocate | Working Towar...',
      'image': 'https://i.pravatar.cc/150?img=9',
      'isVerified': false,
    },
    {
      'name': 'Chris Froster',
      'title': 'Creative UX/UI Designer | Crafting Exceptional User Experiences | Bring...',
      'image': 'https://i.pravatar.cc/150?img=13',
      'isVerified': false,
    },
    {
      'name': 'Angela Joshi',
      'title': 'Strategic Marketing Professional | Brand Enthusiast | Driving Success Throug...',
      'image': 'https://i.pravatar.cc/150?img=24',
      'isVerified': false,
    },
    {
      'name': 'James Bay',
      'title': 'Innovative Entrepreneur | Start-up Enthusiast | Transforming Ideas into Reality',
      'image': 'https://i.pravatar.cc/150?img=8',
      'isVerified': false,
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
          'Memberspage',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '853 Members',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members',
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
          
          // Members list
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return _buildMemberTile(member);
              },
            ),
          ),
          
          // Add button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add member
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(member['image']),
      ),
      title: Row(
        children: [
          Text(
            member['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          if (member['isVerified'])
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.verified,
                color: Colors.blue,
                size: 16,
              ),
            ),
        ],
      ),
      subtitle: Text(
        member['title'],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: () {
          // TODO: Add to friends/group
        },
        icon: const Icon(
          Icons.add_circle_outline,
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}