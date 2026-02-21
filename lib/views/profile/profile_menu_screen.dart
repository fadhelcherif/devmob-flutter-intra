import 'package:devmobi_flutter_intra/views/home/discover.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'user_profile.dart';
import 'edit_profile.dart';
import '../group/create_group.dart';


class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    UserModel? user = await _authService.getUserData(
      _authService.currentUser!.uid,
    );
    setState(() {
      _user = user;
    });
  }

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
                    backgroundImage: NetworkImage(
                      _user?.profileImageUrl ?? 'https://i.pravatar.cc/150?img=5',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user?.name ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfileScreen(),
                        ),
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
            
            _buildMenuItem(Icons.people, 'Members', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiscoverScreen()),
              );
            }),
            
            
            const Divider(),
            
            _buildMenuItem(Icons.manage_accounts, 'Manage Profile', () {
              if (_user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: _user!),
                  ),
                ).then((_) => _loadUser());
              }
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
        style: const  TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}