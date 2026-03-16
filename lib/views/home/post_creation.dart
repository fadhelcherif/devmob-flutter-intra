import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/user_model.dart';
import '../../services/post_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String? groupId;
  final String? groupName;

  const CreatePostScreen({
    super.key,
    this.groupId,
    this.groupName,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  XFile? _selectedImage;
  PlatformFile? _selectedDocument;
  bool _isLoading = false;
  String _uploadStatus = '';

  bool get _isGroupPost => widget.groupId != null && widget.groupId!.isNotEmpty;

  // Pick document (PDF, DOC, etc.)
  Future<void> _pickDocument() async {
    FilePickerResult? result = await _storageService.pickDocument();
    if (result != null) {
      setState(() {
        _selectedDocument = result.files.first;
      });
    }
  }

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
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Choose Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: Use Camera on emulator for quick testing',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_camera, color: theme.primaryColor),
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
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: colorScheme.onSurfaceVariant,
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

  // Create post with or without image/document
  Future<void> _createPost() async {
    if (_textController.text.trim().isEmpty &&
        _selectedImage == null &&
        _selectedDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something or add an image/document'),
        ),
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
        String? documentUrl;
        String? documentName;

        // Upload image if selected
        if (_selectedImage != null) {
          setState(() {
            _uploadStatus = 'Compressing image...';
          });

          await Future.delayed(
            const Duration(milliseconds: 100),
          ); // Allow UI to update

          setState(() {
            _uploadStatus = 'Uploading image...';
          });

          imageUrl = await _storageService.uploadImageFile(
            _selectedImage!,
            'posts/${user.uid}',
          );

          if (imageUrl == null) {
            throw Exception('Failed to upload image');
          }
        }

        // Upload document if selected
        if (_selectedDocument != null) {
          setState(() {
            _uploadStatus = 'Uploading document...';
          });

          documentUrl = await _storageService.uploadDocument(
            _selectedDocument!,
            'documents',
          );
          documentName = _selectedDocument!.name;
        }

        setState(() {
          _uploadStatus = 'Creating post...';
        });

        // Create post
        await _postService.createPost(
          userId: user.uid,
          userName: user.name,
          userImage: user.profileImageUrl ?? 'https://i.pravatar.cc/150',
          groupId: widget.groupId,
          groupName: widget.groupName,
          content: _textController.text.trim(),
          imageUrl: imageUrl,
          documentUrl: documentUrl,
          documentName: documentName,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          _isLoading
              ? (_uploadStatus.isEmpty ? 'Processing...' : _uploadStatus)
              : (_isGroupPost ? 'Group Post' : 'Post'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
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
                    decoration: InputDecoration(
                      hintText: _isGroupPost
                          ? 'Share something with ${widget.groupName ?? 'this group'}'
                          : "What's in your mind?",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  if (_isGroupPost) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Posting in ${widget.groupName ?? 'group'}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

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
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: colorScheme.onSurface,
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

                  // Selected document preview
                  if (_selectedDocument != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedDocument!.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _selectedDocument = null;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed: _showImageSourceDialog,
                  icon: Icon(Icons.image, color: theme.primaryColor),
                ),
                
                IconButton(
                  onPressed: _pickDocument,
                  icon: Icon(
                    Icons.attach_file,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  
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
