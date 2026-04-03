import 'package:devmobi_flutter_intra/views/chat/chat_detail.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
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
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchQuery.trim().isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'People you may know',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                            if (user.uid == currentUser.uid) return false;

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
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return _buildUserCard(users[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imageUrl = user.profileImageUrl;
    final introLine = _buildIntroLine(user);
    final roleLine = _buildRoleLine(user);
    final chipText = _buildSharedInterestLine(user);

    final avatar = (imageUrl != null && imageUrl.trim().isNotEmpty)
        ? CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl))
        : CircleAvatar(
            radius: 30,
            backgroundColor: colorScheme.surface,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: user.uid),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          userName: user.name,
                          userImage:
                              user.profileImageUrl ??
                              'https://i.pravatar.cc/150',
                          receiverId: user.uid,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.message_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
              avatar,
              const SizedBox(height: 8),
              Text(
                user.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                roleLine,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              Text(
                introLine,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.blue.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.people_alt_rounded,
                        size: 11,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        chipText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildRoleLine(UserModel user) {
    if (user.role == UserRole.admin) return 'Admin';
    final bio = user.bio?.trim() ?? '';
    if (bio.contains('/')) return bio;
    return 'Member';
  }

  String _buildIntroLine(UserModel user) {
    final bio = user.bio?.trim() ?? '';
    if (bio.isNotEmpty) return bio;
    final localEmail = user.email.split('@').first;
    final formatted = localEmail
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .trim();
    return formatted.isEmpty ? 'Open to new connections' : formatted;
  }

  String _buildSharedInterestLine(UserModel user) {
    if (user.role == UserRole.admin) {
      return 'Admin';
    }
    return 'User';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
