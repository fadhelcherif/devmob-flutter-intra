// Notifications screen
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'like',
      'user': 'Alex Turner',
      'userImage': 'https://i.pravatar.cc/150?img=11',
      'message': 'liked your post',
      'time': '2 min ago',
      'isRead': false,
    },
    {
      'type': 'comment',
      'user': 'Emma Watson',
      'userImage': 'https://i.pravatar.cc/150?img=5',
      'message': 'commented on your post: "Great insights!"',
      'time': '15 min ago',
      'isRead': false,
    },
    {
      'type': 'follow',
      'user': 'Rahul Vivek',
      'userImage': 'https://i.pravatar.cc/150?img=3',
      'message': 'started following you',
      'time': '1 hour ago',
      'isRead': true,
    },
    {
      'type': 'group_invite',
      'user': 'Priya Wankhede',
      'userImage': 'https://i.pravatar.cc/150?img=9',
      'message': 'invited you to join "Design Thinking" group',
      'time': '3 hours ago',
      'isRead': true,
    },
    {
      'type': 'message',
      'user': 'Akshay Khanna',
      'userImage': 'https://i.pravatar.cc/150?img=12',
      'message': 'sent you a message',
      'time': '5 hours ago',
      'isRead': true,
    },
    {
      'type': 'like',
      'user': 'Maya Sharma',
      'userImage': 'https://i.pravatar.cc/150?img=24',
      'message': 'liked your comment',
      'time': 'Yesterday',
      'isRead': true,
    },
    {
      'type': 'mention',
      'user': 'Chris Dickens',
      'userImage': 'https://i.pravatar.cc/150?img=13',
      'message': 'mentioned you in a post',
      'time': 'Yesterday',
      'isRead': true,
    },
  ];

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.thumb_up;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'group_invite':
        return Icons.group_add;
      case 'message':
        return Icons.message;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'group_invite':
        return Colors.purple;
      case 'message':
        return Colors.orange;
      case 'mention':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

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
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in notifications) {
                  notification['isRead'] = true;
                }
              });
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Color(0xFF2196F3)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return Container(
      color: notification['isRead'] ? Colors.white : const Color(0xFFE3F2FD),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(notification['userImage']),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getIconColor(notification['type']),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  _getIcon(notification['type']),
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 14),
            children: [
              TextSpan(
                text: notification['user'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' ${notification['message']}'),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            notification['time'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        trailing: notification['isRead']
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          setState(() {
            notification['isRead'] = true;
          });
          // TODO: Navigate to relevant screen
        },
      ),
    );
  }
}