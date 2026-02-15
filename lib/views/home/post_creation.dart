import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/post_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  
  XFile? _selectedImage;
  bool _isLoading = false;
  String _uploadStatus = '';

  // Show image source dialog
  Future<void> _showImageSourceDialog() async {
    if (kIsWeb) {
      // On web, directly pick from gallery
      _pickImage(ImageSource.gallery);
      return;
    }

    // On mobile, show dialog to choose camera or gallery
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Choose Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: Use Camera on emulator for quick testing',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from photos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    XFile? image = await _storageService.pickImageWithSource(source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Create post with or without image
  Future<void> _createPost() async {
    if (_textController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something or add an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      UserModel? user = await _authService.getUserData(
        _authService.currentUser!.uid,
      );

      if (user != null) {
        String? imageUrl;
        
        // Upload image if selected
        if (_selectedImage != null) {
          setState(() {
            _uploadStatus = 'Compressing image...';
          });
          
          await Future.delayed(const Duration(milliseconds: 100)); // Allow UI to update
          
          setState(() {
            _uploadStatus = 'Uploading image...';
          });
          
          imageUrl = await _storageService.uploadImageFile(
            _selectedImage!, 
            'posts/${user.uid}'
          );
          
          if (imageUrl == null) {
            throw Exception('Failed to upload image');
          }
          
          setState(() {
            _uploadStatus = 'Creating post...';
          });
        }

        // Create post
        await _postService.createPost(
          userId: user.uid,
          userName: user.name,
          userImage: user.profileImageUrl ?? 'https://i.pravatar.cc/150',
          content: _textController.text.trim(),
          imageUrl: imageUrl,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
        }
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
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
        title: _isLoading
            ? Text(
                _uploadStatus.isEmpty ? 'Processing...' : _uploadStatus,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            : const Text(
                'Post',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Text input
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: "What's in your mind?",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  
                  // Selected image preview
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<Uint8List>(
                      future: _selectedImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  snapshot.data!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Remove image button
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                ),
                IconButton(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.image, color: Color(0xFF2196F3)),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}