import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfileScreen({super.key, this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  File? _selectedImageFile;
  Uint8List? _webImageBytes;
  String? _existingAvatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _extractUserObject(widget.userData);
    _nameController = TextEditingController(text: user['name'] ?? '');
    _bioController = TextEditingController(text: user['bio'] ?? '');
    _existingAvatarUrl = user['avatarUrl'];
  }

  Map<String, dynamic> _extractUserObject(Map<String, dynamic>? rawData) {
    if (rawData == null) return {};
    if (rawData.containsKey('user') && rawData['user'] is Map<String, dynamic>) {
      return rawData['user'] as Map<String, dynamic>;
    }
    return rawData;
  }

  String? _getUserId(Map<String, dynamic> user) {
    return user['_id'] ?? user['id'] ?? user['userId'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _selectedImageFile = null;
        });
      } else {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _extractUserObject(widget.userData);
    final userId = _getUserId(user);

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not identify valid User ID.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // For Android Emulator use 10.0.2.2; for real devices/desktop use localhost or host IP
      final baseUrl = kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
      final uri = Uri.parse('$baseUrl/api/users/profile/$userId');

      var request = http.MultipartRequest('PUT', uri);
      request.fields['name'] = _nameController.text.trim();
      request.fields['bio'] = _bioController.text.trim();

      if (_selectedImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', _selectedImageFile!.path),
        );
      } else if (_webImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'avatar',
            _webImageBytes!,
            filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final updatedUser = data['user'];

        // Persist locally in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final fullUserData = widget.userData ?? {};
        if (fullUserData.containsKey('user')) {
          fullUserData['user'] = updatedUser;
          await prefs.setString('userData', jsonEncode(fullUserData));
        } else {
          await prefs.setString('userData', jsonEncode(updatedUser));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, updatedUser);
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to save changes.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (_selectedImageFile != null) {
      avatarImage = FileImage(_selectedImageFile!);
    } else if (_webImageBytes != null) {
      avatarImage = MemoryImage(_webImageBytes!);
    } else if (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(_existingAvatarUrl!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF2563EB),
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Text(
                        (_nameController.text.isNotEmpty ? _nameController.text[0] : 'U').toUpperCase(),
                        style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                      )
                          : null,
                    ),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Choose Photo from Gallery'),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}