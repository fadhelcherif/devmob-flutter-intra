import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'edit_profile.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';

class UserProfileScreen extends StatefulWidget {
  final String? userId;

  const UserProfileScreen({super.key, this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  UserModel? _user;
  bool _isLoading = true;

  bool get _isOwnProfile {
    final currentUid = _authService.currentUser?.uid;
    if (currentUid == null) return false;
    final viewingUid = widget.userId;
    return viewingUid == null || viewingUid == currentUid;
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      String uid = widget.userId ?? _authService.currentUser!.uid;
      UserModel? user = await _authService.getUserData(uid);

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          _isOwnProfile ? 'My Profile' : 'Profile',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: _isOwnProfile
            ? [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: _user!),
                      ),
                    ).then((_) => _loadUser());
                  },
                  icon: const Icon(Icons.edit),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      _user!.profileImageUrl ?? 'https://i.pravatar.cc/150',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user!.role.name.toUpperCase(),
                          style: TextStyle(
                            color: _user!.role == UserRole.admin
                                ? colorScheme.error
                                : theme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user!.email,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // About
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'About',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                (_user!.bio != null && _user!.bio!.isNotEmpty)
                    ? _user!.bio!
                    : 'No bio added yet.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isOwnProfile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileScreen(user: _user!),
                            ),
                          ).then((_) => _loadUser());
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.primaryColor),
                          foregroundColor: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _isOwnProfile ? 'My Posts' : 'Posts',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // User posts list
            StreamBuilder<List<PostModel>>(
              stream: _postService.getUserPosts(
                widget.userId ?? _authService.currentUser!.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No posts yet'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostItem(post);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostItem(PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    _user!.profileImageUrl ?? 'https://i.pravatar.cc/150',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _user!.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (post.documentUrl != null && post.documentName != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(post.documentUrl!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.documentName!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.open_in_new, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likes.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.comment,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.commentsCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(post.createdAt),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
