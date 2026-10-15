import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_flushbar/flushbar.dart';
import '../services/auth_service.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user.dart';
import 'profile_personal_info_screen.dart';
import 'profile_security_screen.dart';
import 'profile_about_us_screen.dart';
import 'profile_contact_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Design system tokens based on Cybernetic Orbit
  static const Color bgColor = Color(0xFF091422);
  static const Color surface = Color(0xFF15202F);
  static const Color surfaceHigh = Color(0xFF202B3A);
  static const Color primaryMint = Color(0xFF85FFDE);
  static const Color mainText = Color(0xFFD8E3F7);
  static const Color secondaryText = Color(0xFFBACAC3);
  static const Color errorColor = Color(0xFFFFB4AB);

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  
  User? _currentUser;
  bool _isLoadingUser = true;

  // Rate Us state
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final user = await _userRepository.getUserById(userId);
        if (mounted && user != null) {
          setState(() {
            _currentUser = user;
            if (user.profileImagePath != null) {
              final file = File(user.profileImagePath!);
              if (file.existsSync()) {
                _profileImage = file;
              }
            }
            _isLoadingUser = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) return;
    
    setState(() {
      _isSubmittingReview = true;
    });

    // Simulate async network request
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isSubmittingReview = false;
      _rating = 0;
      _reviewController.clear();
    });

    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: primaryMint,
      icon: const Icon(Icons.check_circle, color: bgColor, size: 24),
      messageText: const Text(
        'Review submitted successfully',
        style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: bgColor, fontWeight: FontWeight.bold),
      ),
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && _currentUser != null) {
        final newPath = pickedFile.path;
        
        // Save to DB
        final updatedUser = _currentUser!.copyWith(profileImagePath: newPath);
        await _userRepository.updateUser(updatedUser);

        setState(() {
          _profileImage = File(newPath);
          _currentUser = updatedUser;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e', style: const TextStyle(fontFamily: 'Plus Jakarta Sans')),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) Navigator.pop(context); // Close bottom sheet
  }

  void _showChangePhotoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Change Photo",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: mainText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPhotoOption(
                  icon: Icons.photo_library_outlined,
                  text: 'Choose from Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 12),
                _buildPhotoOption(
                  icon: Icons.camera_alt_outlined,
                  text: 'Take a Photo',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 12),
                _buildPhotoOption(
                  icon: Icons.close,
                  text: 'Cancel',
                  onTap: () => Navigator.pop(context),
                  isCancel: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({required IconData icon, required String text, required VoidCallback onTap, bool isCancel = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isCancel ? Colors.transparent : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCancel ? surfaceHigh : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isCancel ? secondaryText : primaryMint, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: isCancel ? secondaryText : mainText,
                fontSize: 16,
                fontWeight: isCancel ? FontWeight.w600 : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPersonalInfo() async {
    if (_currentUser == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePersonalInfoScreen(
          userId: _currentUser!.id!,
          initialFirstName: _currentUser!.firstName,
          initialLastName: _currentUser!.lastName,
          initialEmail: _currentUser!.email,
          initialPhone: _currentUser!.phoneNumber ?? '',
        ),
      ),
    );

    if (result != null && result == true) {
      // Reload profile
      await _loadUserProfile();
      
      // Show Flushbar
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: primaryMint,
        icon: const Icon(Icons.check_circle, color: bgColor, size: 24),
        messageText: const Text(
          'Personal information updated',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: bgColor, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  void _navigateToSecurity() async {
    if (_currentUser == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileSecurityScreen(userId: _currentUser!.id!)),
    );

    if (result == true) {
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: primaryMint,
        icon: const Icon(Icons.shield_outlined, color: bgColor, size: 24),
        messageText: const Text(
          'Password updated successfully',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: bgColor, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  void _navigateToAboutUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileAboutUsScreen()),
    );
  }

  void _navigateToContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileContactUsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return Container(
        color: bgColor,
        child: const Center(
          child: CircularProgressIndicator(color: primaryMint),
        ),
      );
    }

    // Determine values to show
    final firstName = _currentUser?.firstName ?? "Unknown";
    final lastName = _currentUser?.lastName ?? "User";
    final experience = _currentUser?.experienceLevel ?? "Not specified";
    String roleSubtitle = "Robotics Enthusiast";
    
    // Customize subtitle if we have experience level from DB
    if (experience != "Not specified") {
      // Capitalize first letter
      roleSubtitle = "${experience[0].toUpperCase()}${experience.substring(1)} Builder";
    }

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: mainText),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainText,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 156), // Pad bottom for floating nav bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceHigh,
                              border: Border.all(color: surface, width: 4),
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryMint.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: _profileImage == null
                                ? const Icon(Icons.person_outline, size: 60, color: secondaryText)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showChangePhotoBottomSheet,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryMint,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: bgColor, width: 3),
                                ),
                                child: const Icon(Icons.camera_alt, color: bgColor, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "$firstName $lastName".trim(),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleSubtitle,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: primaryMint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showChangePhotoBottomSheet,
                      child: const Text(
                        "Change Photo",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: secondaryText,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Account Settings Sections
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Account Settings",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mainText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSettingsRow(
                      icon: Icons.person_outline,
                      title: "Personal Information",
                      description: "Manage your personal details",
                      onTap: _navigateToPersonalInfo,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      icon: Icons.shield_outlined,
                      title: "Security",
                      description: "Password and account security",
                      onTap: _navigateToSecurity,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      icon: Icons.info_outline,
                      title: "About Us",
                      description: "Discover the ROBOTTO community",
                      onTap: _navigateToAboutUs,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      icon: Icons.mail_outline,
                      title: "Contact Us",
                      description: "Get help or contact the ROBOTTO team",
                      onTap: _navigateToContactUs,
                    ),
                    const SizedBox(height: 48),

                    // --- Rate Us Section ---
                    const Row(
                      children: [
                        Icon(Icons.star_outline, color: primaryMint, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Rate Us",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: mainText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Share your experience with ROBOTTO.",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Interactive 5-star rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isSelected = index < _rating;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                              child: Icon(
                                isSelected ? Icons.star : Icons.star_border,
                                key: ValueKey<bool>(isSelected),
                                color: isSelected ? primaryMint : secondaryText,
                                size: 44,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Review text field
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      maxLength: 500,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: mainText,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: "Tell us what you think about ROBOTTO...",
                        hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
                        filled: true,
                        fillColor: surface,
                        contentPadding: const EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: primaryMint, width: 1.5),
                        ),
                        counterStyle: const TextStyle(color: secondaryText, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryMint,
                          disabledBackgroundColor: surfaceHigh,
                          foregroundColor: bgColor,
                          disabledForegroundColor: secondaryText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: (_rating > 0 && !_isSubmittingReview) ? _submitReview : null,
                        child: _isSubmittingReview
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: bgColor,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryMint, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: mainText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: secondaryText),
          ],
        ),
      ),
    );
  }
}
