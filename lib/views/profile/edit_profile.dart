import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'dart:io';
import '../../services/storage_service.dart';
import 'package:image_picker/image_picker.dart';


class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  XFile? _selectedImage;
  bool _isUploadingImage = false;
  
  bool _isLoading = false;

  Future<void> _pickProfileImage() async {
  XFile? image = await _storageService.pickProfileImage();
  if (image != null) {
    setState(() {
      _selectedImage = image;
    });
    _uploadProfileImage(image);
  }
}

Future<void> _uploadProfileImage(XFile image) async {
  setState(() {
    _isUploadingImage = true;
  });
  
  String? url = await _storageService.uploadProfileImage(image);
  
  if (url != null) {
    // Update user profile with new image URL
    await _authService.updateUserProfile(
      widget.user.uid,
      {'profileImageUrl': url},
    );
    
    setState(() {
      _isUploadingImage = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image updated!')),
    );
  } else {
    setState(() {
      _isUploadingImage = false;
    });
  }
}

  @override
  void initState() {
    super.initState();
    // Pre-fill with current data
    _nameController.text = widget.user.name;
    _bioController.text = widget.user.bio ?? '';
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.updateUserProfile(
        widget.user.uid,
        {
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          icon: const Icon(Icons.close, color: Colors.black),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path)) as ImageProvider
                        : NetworkImage(
                            widget.user.profileImageUrl ?? 'https://i.pravatar.cc/150',
                          ),
                  ),
                  Positioned(
  bottom: 0,
  right: 0,
  child: GestureDetector(
    onTap: _isUploadingImage ? null : _pickProfileImage,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3),
        shape: BoxShape.circle,
      ),
      child: _isUploadingImage
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
    ),
  ),
),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Name field
            _buildTextField(
              label: 'Name',
              controller: _nameController,
            ),
            
            const SizedBox(height: 16),
            
            // Bio field
            _buildTextField(
              label: 'Bio',
              controller: _bioController,
              maxLines: 3,
              hint: 'Tell us about yourself...',
            ),
            
            const SizedBox(height: 16),
            
            // Email (read-only)
            _buildTextField(
              label: 'Email',
              controller: TextEditingController(text: widget.user.email),
              enabled: false,
            ),
            
            const SizedBox(height: 16),
            
            // Role (read-only)
            _buildTextField(
              label: 'Role',
              controller: TextEditingController(
                text: widget.user.role.name.toUpperCase(),
              ),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, 
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _jobTitleController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}