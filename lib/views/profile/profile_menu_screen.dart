import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'user_profile.dart';
import 'edit_profile.dart';
import '../group/create_group.dart';
import '../group/mygroup.dart';
import 'myconnections.dart';


class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=5'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sarah Jhonson',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                  onPressed: () {
                      Navigator.push(
                    context,
                  MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                      );
                      },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2196F3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(color: Color(0xFF2196F3)),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Menu items
            _buildMenuItem(Icons.group_add, 'Create Group', () {
               Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              );
        }),
            
            _buildMenuItem(Icons.connect_without_contact, 'My Connections', () {
             Navigator.push(
              context,
             MaterialPageRoute(builder: (context) => const MyConnectionsScreen()),
              );
            }),   
        
            _buildMenuItem(Icons.groups, 'My Groups', () {
               Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const GroupDetailScreen()),
              );
            }),
            
            const Divider(),
            
            _buildMenuItem(Icons.manage_accounts, 'Manage Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),

              );
            }),
            _buildMenuItem(Icons.settings, 'Settings', () {
              // TODO: Settings
            }),
            _buildMenuItem(Icons.logout, 'Logout', () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}