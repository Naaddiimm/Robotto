import 'package:flutter/material.dart';
import '../data/repositories/user_repository.dart';

class ProfilePersonalInfoScreen extends StatefulWidget {
  final int userId;
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String initialPhone;

  const ProfilePersonalInfoScreen({
    super.key,
    required this.userId,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialEmail,
    required this.initialPhone,
  });

  @override
  State<ProfilePersonalInfoScreen> createState() => _ProfilePersonalInfoScreenState();
}

class _ProfilePersonalInfoScreenState extends State<ProfilePersonalInfoScreen> {
  // Cybernetic Orbit Colors
  static const Color bgColor = Color(0xFF091422);
  static const Color surfaceHigh = Color(0xFF202B3A);
  static const Color surface = Color(0xFF15202F);
  static const Color primaryMint = Color(0xFF85FFDE);
  static const Color mainText = Color(0xFFD8E3F7);
  static const Color secondaryText = Color(0xFFBACAC3);
  static const Color errorColor = Color(0xFFFFB4AB);

  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepo = UserRepository();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // Fetch current user, update and save
    try {
      final user = await _userRepo.getUserById(widget.userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _userRepo.updateUser(updatedUser);
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      // Return true to parent to trigger reload and notification
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: mainText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Personal Information",
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
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Update your details",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: mainText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Keep your personal information up to date.",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: secondaryText,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _firstNameController,
                        label: "First Name",
                        icon: Icons.person_outline,
                        validator: (value) => value == null || value.trim().isEmpty ? 'First name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _lastNameController,
                        label: "Last Name",
                        icon: Icons.badge_outlined,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Last name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        label: "Email Address",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        label: "Phone Number",
                        hintText: "Optional",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 40),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryMint,
                            foregroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isSaving ? null : _handleSave,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: bgColor,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: secondaryText,
                            side: const BorderSide(color: surfaceHigh, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: mainText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: mainText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
            prefixIcon: Icon(icon, color: secondaryText, size: 20),
            filled: true,
            fillColor: surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryMint, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorColor, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
