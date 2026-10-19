import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../user/screens/signin_screen.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/data/repositories/user_repository.dart';
import '../../../core/data/models/user.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {

  // Cybernetic Orbit Colors
  static const Color bgColor = AppTheme.bg;
  static const Color surface = AppTheme.surface;
  static const Color surfaceHigh = AppTheme.surfaceHigh;
  static const Color mainText = AppTheme.text;
  static const Color secondaryText = AppTheme.textSoft;
  static const Color errorColor = AppTheme.error;

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  
  User? _currentUser;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user in drawer: $e");
    }
  }

  void _handleLogout(BuildContext context) {
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
            Icon(Icons.logout, color: errorColor),
            SizedBox(width: 12),
            Text(
              "Log Out",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: mainText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
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
              // Store the context for Navigator since the dialog context will be destroyed
              final navigatorContext = context;
              
              // Close the dialog
              Navigator.pop(context);

              // Execute actual authentication logout logic
              await _authService.logout();

              // Navigate to Sign In and clear navigation stack
              if (!navigatorContext.mounted) return;
              Navigator.pushAndRemoveUntil(
                navigatorContext,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Log Out",
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
    final String displayName = _currentUser != null 
        ? "${_currentUser!.firstName} ${_currentUser!.lastName}".trim() 
        : "Loading...";
    final String displayEmail = _currentUser?.email ?? "";

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Info Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfaceHigh,
                      border: Border.all(color: surface, width: 3),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? const Icon(
                            Icons.person_outline,
                            size: 40,
                            color: secondaryText,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (displayEmail.isNotEmpty)
                    Text(
                      displayEmail,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            
            const Divider(color: surface, thickness: 1.5, height: 1),
            
            // Spacer to push Logout button to the bottom
            const Spacer(),

            const Divider(color: surface, thickness: 1.5, height: 1),
            
            // Logout Action
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () => _handleLogout(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: errorColor.withValues(alpha: 0.1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: errorColor, size: 22),
                      SizedBox(width: 16),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: errorColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
