import 'package:devmobi_flutter_intra/views/home/discover.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'user_profile.dart';
import 'edit_profile.dart';
import '../group/create_group.dart';
import '../group/my_groups_screen.dart';
import 'settings.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

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
    final theme = Theme.of(context);
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
                      _user?.profileImageUrl ??
                          'https://i.pravatar.cc/150?img=5',
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
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'View Profile',
                      style: TextStyle(color: theme.primaryColor),
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
                MaterialPageRoute(
                  builder: (context) => const CreateGroupScreen(),
                ),
              );
            }),

            _buildMenuItem(Icons.people, 'Members', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiscoverScreen()),
              );
            }),

            _buildMenuItem(Icons.groups, 'My Groups', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyGroupsScreen()),
              );
            }),

            const Divider(),

            if (_user?.role == UserRole.admin)
              _buildMenuItem(Icons.person_add_alt_1, 'Create Account', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupScreen(adminMode: true),
                  ),
                );
              }),

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),
            _buildMenuItem(Icons.logout, 'Logout', () async {
              await _logout();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
