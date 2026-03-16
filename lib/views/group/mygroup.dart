import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../models/post_model.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';
import '../home/post_creation.dart';
import '../home/post_detail_screen.dart';
import 'group_chat_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  GroupModel? _group;
  bool _isLoading = true;
  bool _isMember = false;
  bool _isPending = false;
  bool _isCreator = false;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    try {
      GroupModel? group = await _groupService.getGroup(widget.groupId);
      String currentUserId = _authService.currentUser!.uid;

      setState(() {
        _group = group;
        if (group != null) {
          _isMember = group.members.contains(currentUserId);
          _isPending = group.pendingMembers.contains(currentUserId);
          _isCreator = group.createdBy == currentUserId;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinGroup() async {
    try {
      if (_group!.isPublic) {
        // Public group - join immediately
        await _groupService.joinGroup(
          widget.groupId,
          _authService.currentUser!.uid,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Joined group!')));
      } else {
        // Private group - send request
        await _groupService.requestToJoinGroup(
          widget.groupId,
          _authService.currentUser!.uid,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to group creator')),
        );
      }
      _loadGroup();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _leaveGroup() async {
    try {
      await _groupService.leaveGroup(
        widget.groupId,
        _authService.currentUser!.uid,
      );
      _loadGroup();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Left group')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _cancelRequest() async {
    try {
      await _groupService.rejectMember(
        widget.groupId,
        _authService.currentUser!.uid,
      );
      _loadGroup();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request cancelled')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_group == null) {
      return const Scaffold(body: Center(child: Text('Group not found')));
    }

    final group = _group!;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Group',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          if (_isMember)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatScreen(groupId: widget.groupId),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<PostModel>>(
          stream: _isMember ? _postService.getGroupPosts(widget.groupId) : null,
          builder: (context, postSnapshot) {
            final groupPosts = postSnapshot.data ?? const <PostModel>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Group info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 40,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        group.isPublic ? Icons.public : Icons.lock,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        group.isPublic ? 'Public Group' : 'Private Group',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    group.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('${group.members.length}', 'Members'),
                  _buildStatDivider(),
                  if (!group.isPublic)
                    _buildStat('${group.pendingMembers.length}', 'Pending'),
                  if (!group.isPublic) _buildStatDivider(),
                  _buildStat('${groupPosts.length}', 'Posts'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Creator info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(group.creatorImage),
                ),
                title: const Text('Created by'),
                subtitle: Text(group.creatorName),
              ),
            ),

            // Show pending requests if creator
            if (_isCreator &&
                !group.isPublic &&
                group.pendingMembers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pending Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildPendingList(),
            ],

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Group Hub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isMember)
                    FloatingActionButton.small(
                      heroTag: 'group_post_fab_${widget.groupId}',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePostScreen(
                              groupId: group.id,
                              groupName: group.name,
                            ),
                          ),
                        );
                        if (mounted) {
                          _loadGroup();
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                ],
              ),
            ),

            if (_isMember && postSnapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_isMember && groupPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.forum_outlined, size: 36),
                      SizedBox(height: 12),
                      Text(
                        'No group posts yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Start the conversation with the first post.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_isMember)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                itemCount: groupPosts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final post = groupPosts[index];
                  return _buildGroupPostCard(post);
                },
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    group.isPublic
                        ? 'Join this group to publish and view member posts in the hub.'
                        : 'Become a member to unlock the private group hub and post feed.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),

            const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildGroupPostCard(PostModel post) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLikedByCurrentUser = post.likes.contains(
      _authService.currentUser?.uid,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.userImage)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _getTimeAgo(post.createdAt),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(post.content, style: const TextStyle(height: 1.4)),
            ],
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 16,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text('${post.likes.length}'),
                const SizedBox(width: 16),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text('${post.commentsCount}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPostActionButton(
                  icon: isLikedByCurrentUser ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: 'Like',
                  color: isLikedByCurrentUser
                      ? theme.primaryColor
                      : colorScheme.onSurfaceVariant,
                  onTap: () => _likePost(post),
                ),
                _buildPostActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Comment',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final Color resolvedColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: resolvedColor, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: resolvedColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _likePost(PostModel post) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _postService.likePost(post.id, userId);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  Widget _buildBottomButton() {
    if (_isMember) {
      final colorScheme = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _leaveGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Leave Group'),
          ),
        ),
      );
    }

    if (_isPending) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _cancelRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
            ),
            child: const Text('Cancel Request'),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _joinGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text(_group!.isPublic ? 'Join Group' : 'Request to Join'),
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    return Column(
      children: _group!.pendingMembers.map((userId) {
        return FutureBuilder(
          future: _authService.getUserData(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final user = snapshot.data!;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  user.profileImageUrl ?? 'https://i.pravatar.cc/150',
                ),
              ),
              title: Text(user.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      await _groupService.approveMember(widget.groupId, userId);
                      _loadGroup();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      await _groupService.rejectMember(widget.groupId, userId);
                      _loadGroup();
                    },
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}
