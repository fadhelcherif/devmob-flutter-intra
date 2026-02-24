import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import 'group_chat.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
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
        await _groupService.joinGroup(widget.groupId, _authService.currentUser!.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined group!')),
        );
      } else {
        // Private group - send request
        await _groupService.requestToJoinGroup(widget.groupId, _authService.currentUser!.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to group creator')),
        );
      }
      _loadGroup();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _leaveGroup() async {
    try {
      await _groupService.leaveGroup(widget.groupId, _authService.currentUser!.uid);
      _loadGroup();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Left group')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _cancelRequest() async {
    try {
      await _groupService.rejectMember(widget.groupId, _authService.currentUser!.uid);
      _loadGroup();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return const Scaffold(
        body: Center(child: Text('Group not found')),
      );
    }

    final group = _group!;

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
          'Group',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (_isMember)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailScreen(groupId: widget.groupId),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2196F3)),
              label: const Text(
                'Chat',
                style: TextStyle(color: Color(0xFF2196F3)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2196F3),
                    child: Text(
                      group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
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
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        group.isPublic ? 'Public Group' : 'Private Group',
                        style: TextStyle(
                          color: Colors.grey[600],
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
                      color: Colors.grey[700],
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
                  if (!group.isPublic) _buildStat('${group.pendingMembers.length}', 'Pending'),
                  if (!group.isPublic) _buildStatDivider(),
                  _buildStat('0', 'Posts'),
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
            if (_isCreator && !group.isPublic && group.pendingMembers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pending Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildPendingList(),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildBottomButton() {
    if (_isMember) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _leaveGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave Group'),
          ),
        ),
      );
    }

    if (_isPending) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _cancelRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Request'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _joinGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
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
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await _groupService.approveMember(widget.groupId, userId);
                      _loadGroup();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
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
      color: Colors.grey[300],
    );
  }
}