import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../profile/user_profile.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();

  String _searchQuery = '';

  Stream<QuerySnapshot<Map<String, dynamic>>> get _usersStream =>
      FirebaseFirestore.instance
          .collection('users')
          .orderBy('name')
          .snapshots();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text;
      if (next == _searchQuery) return;
      setState(() {
        _searchQuery = next;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

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
          'Members',
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _usersStream,
                builder: (context, snapshot) {
                  final total = snapshot.data?.docs.length;
                  final label = total == null ? 'Members' : '$total Members';
                  return Text(
                    label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please login to discover members.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search members',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.trim().isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
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
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _usersStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load members',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final query = _searchQuery.trim().toLowerCase();

                      final users = snapshot.data!.docs
                          .map((doc) {
                            final data = doc.data();
                            final merged = <String, dynamic>{
                              ...data,
                              'uid': data['uid'] ?? doc.id,
                            };
                            return UserModel.fromMap(merged);
                          })
                          .where((user) {
                            if (query.isEmpty) return true;
                            return user.name.toLowerCase().contains(query) ||
                                user.email.toLowerCase().contains(query);
                          })
                          .toList();

                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            query.isEmpty
                                ? 'No members found.'
                                : 'No results for "$query"',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          return _buildUserTile(users[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    final imageUrl = user.profileImageUrl;

    final avatar = (imageUrl != null && imageUrl.trim().isNotEmpty)
        ? CircleAvatar(radius: 22, backgroundImage: NetworkImage(imageUrl))
        : CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[200],
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

    return ListTile(
      leading: avatar,
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        (user.bio != null && user.bio!.trim().isNotEmpty)
            ? user.bio!
            : user.email,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Message'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(userId: user.uid),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Profile'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
