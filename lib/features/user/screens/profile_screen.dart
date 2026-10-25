import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/data/repositories/user_repository.dart';
import '../../../core/data/models/user.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_personal_info_screen.dart';
import 'profile_security_screen.dart';
import 'profile_about_us_screen.dart';
import 'profile_contact_us_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Design system tokens based on Cybernetic Orbit
  static const Color bgColor = AppTheme.bg;
  static const Color surface = AppTheme.surface;
  static const Color surfaceHigh = AppTheme.surfaceHigh;
  static const Color primaryMint = AppTheme.accent;
  static const Color mainText = AppTheme.text;
  static const Color secondaryText = AppTheme.textSoft;
  static const Color errorColor = AppTheme.error;

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
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          if (user?.profileImagePath != null) {
            final file = File(user!.profileImagePath!);
            if (file.existsSync()) {
              _profileImage = file;
            }
          }
          _isLoadingUser = false;
        });
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
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: bgColor,
          fontWeight: FontWeight.bold,
        ),
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
            content: Text(
              'Failed to pick image: $e',
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
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
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
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

  Widget _buildPhotoOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isCancel ? Colors.transparent : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancel ? surfaceHigh : Colors.transparent,
          ),
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
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: bgColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  void _navigateToSecurity() async {
    if (_currentUser == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSecurityScreen(userId: _currentUser!.id!),
      ),
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
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: bgColor,
            fontWeight: FontWeight.bold,
          ),
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surface, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: errorColor),
            SizedBox(width: 12),
            Text(
              "Delete Account",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: mainText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.",
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor.withValues(alpha: 0.1),
              foregroundColor: errorColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final navigatorContext = context;
              Navigator.pop(context); // Close dialog

              if (_currentUser?.id != null) {
                // Delete user from Database
                await _userRepository.deleteUser(_currentUser!.id!);
                // Clear session
                await _authService.logout();

                if (!navigatorContext.mounted) return;

                // Redirect to Welcome Screen
                Navigator.pushAndRemoveUntil(
                  navigatorContext,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
      roleSubtitle =
          "${experience[0].toUpperCase()}${experience.substring(1)} Builder";
    }

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Robotto branding
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ROBOTT',
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accent, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Bell icon
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  156,
                ), // Pad bottom for floating nav bar
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
                                ),
                              ],
                            ),
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.person_outline,
                                    size: 60,
                                    color: secondaryText,
                                  )
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
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: bgColor,
                                  size: 16,
                                ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
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
                        hintStyle: const TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                        ),
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
                          borderSide: const BorderSide(
                            color: primaryMint,
                            width: 1.5,
                          ),
                        ),
                        counterStyle: const TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
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
                        onPressed: (_rating > 0 && !_isSubmittingReview)
                            ? _submitReview
                            : null,
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
                    const SizedBox(height: 48),

                    // --- Delete Account Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: errorColor,
                          side: BorderSide(
                            color: errorColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _showDeleteAccountDialog,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Delete My Account',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
