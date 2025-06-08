// lib/screens/user_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/user_manager.dart';
import '../widgets/bottom_nav.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  String _selectedSkinType = 'Normal';
  String _selectedAge = '25-34';

  final List<String> _skinTypes = [
    'Normal',
    'Dry',
    'Oily',
    'Combination',
    'Sensitive'
  ];
  final List<String> _ageRanges = ['18-24', '25-34', '35-44', '45-54', '55+'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load existing user data if available
    final user = UserManager.currentUser;
    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['phone'] ?? '';
      _bioController.text = user['bio'] ?? '';
      _selectedSkinType = user['skin_type'] ?? 'Normal';
      _selectedAge = user['age_range'] ?? '25-34';
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: Theme.of(context).primaryColor),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library,
                    color: Theme.of(context).primaryColor),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

// Replace the _pickImage method in your UserProfileScreen

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check platform and permissions first
      if (Platform.isAndroid) {
        // For Android emulator, we'll use a more robust approach
        final picker = ImagePicker();

        // Try to pick image with specific parameters for emulator
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (pickedFile != null) {
          final File imageFile = File(pickedFile.path);

          // Verify file exists and is readable
          if (await imageFile.exists()) {
            setState(() {
              _profileImage = imageFile;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile photo updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            print('✅ Image selected: ${pickedFile.path}');
          } else {
            throw Exception('Selected image file does not exist');
          }
        } else {
          print('ℹ️ No image selected by user');
        }
      }
    } catch (e) {
      print('❌ Error selecting image: $e');

      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Camera not available on emulator. Try using a real device or select from gallery.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );

      // Fallback: Try gallery if camera failed
      if (source == ImageSource.camera) {
        print('🔄 Camera failed, trying gallery...');
        await _pickImage(ImageSource.gallery);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Update user data (in a real app, this would save to your backend)
      final updatedUser = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'skin_type': _selectedSkinType,
        'age_range': _selectedAge,
        'profile_image_path': _profileImage?.path,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Save to local storage (you can extend this to save to your API)
      UserManager.updateUserProfile(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
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

            SizedBox(height: 32),

            // Basic Info Section
            _buildSectionTitle('Basic Information'),
            SizedBox(height: 16),

            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              required: true,
            ),

            SizedBox(height: 16),

            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 16),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 24),

            // Skincare Info Section
            _buildSectionTitle('Skincare Profile'),
            SizedBox(height: 16),

            _buildDropdownField(
              value: _selectedSkinType,
              label: 'Skin Type',
              icon: Icons.face_outlined,
              items: _skinTypes,
              onChanged: (value) => setState(() => _selectedSkinType = value!),
            ),

            SizedBox(height: 16),

            _buildDropdownField(
              value: _selectedAge,
              label: 'Age Range',
              icon: Icons.cake_outlined,
              items: _ageRanges,
              onChanged: (value) => setState(() => _selectedAge = value!),
            ),

            SizedBox(height: 16),

            _buildTextField(
              controller: _bioController,
              label: 'About Me',
              icon: Icons.edit_outlined,
              maxLines: 3,
              hint: 'Tell us about your skincare goals and concerns...',
            ),

            SizedBox(height: 32),

            // Device Info Section (from AppProvider)
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Status',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        provider.getDeviceStatusSummary(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (provider.location != null) ...[
                        SizedBox(height: 8),
                        Text(
                          provider.getClimateRecommendation(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
