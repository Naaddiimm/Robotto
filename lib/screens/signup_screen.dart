import 'package:flutter/material.dart';
import 'signin_screen.dart'; // Import SignInScreen
import 'interests_screen.dart'; // Import InterestsScreen
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _registrationError;
  String _selectedEducation = "Secondary School";

  // Design system tokens based on DESIGN.md
  static const Color bgColor = Color(0xFF091422);
  static const Color surfaceLow = Color(0xFF111C2B);
  static const Color surface = Color(0xFF15202F);
  static const Color primaryMint = Color(0xFF85FFDE);
  static const Color primaryContainer = Color(0xFF35E6C0);
  static const Color mainText = Color(0xFFD8E3F7);
  static const Color secondaryText = Color(0xFFBACAC3);
  static const Color errorColor = Color(0xFFFFB4AB);

  final List<String> _educationOptions = [
    "Secondary School",
    "University Student",
    "Engineering Student",
    "Graduate",
    "Professional",
    "Self-taught",
    "Other"
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showEducationBottomSheet() {
    // Unfocus keyboard if open before showing bottom sheet
    FocusScope.of(context).unfocus();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      "Select Education Level",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: mainText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _educationOptions.map((option) {
                          final isSelected = option == _selectedEducation;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedEducation = option;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                              color: isSelected ? surface : Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: isSelected ? primaryMint : mainText,
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: primaryMint),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    setState(() {
      _registrationError = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final userId = await _authService.registerUser(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          educationLevel: _selectedEducation,
        );

        if (!mounted) return;
        
        setState(() {
          _isSubmitting = false;
        });

        // Show success dialog prototype
        showDialog(
          context: context,
          barrierDismissible: false, // Force them to hit continue
          builder: (context) => AlertDialog(
            backgroundColor: surfaceLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: surface, width: 1),
            ),
            title: const Column(
              children: [
                Icon(Icons.check_circle_outline, color: primaryMint, size: 48),
                SizedBox(height: 16),
                Text(
                  "Account Created!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: mainText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "Welcome to ROBOTTO, ${_firstNameController.text.trim()}! You're ready to explore the community.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: secondaryText,
              ),
            ),
            actions: [
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryMint, primaryContainer],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to Interests Screen (Step 1 of Onboarding), passing userId
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => InterestsScreen(userId: userId)),
                    );
                  },
                  child: const Text(
                    'Continue to Onboarding',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: bgColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _registrationError = e.toString().replaceAll("Exception: ", "");
          });
        }
      }
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
                    "ROBOTTO",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainText,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo with glow
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryMint.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 60,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 60,
                              width: 60,
                              decoration: const BoxDecoration(
                                color: surface,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'LOGO\nMISSING',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryMint,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Headings
                      const Text(
                        "Create Your Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mainText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Join the robotics community, discover new opportunities, and bring your ideas to life.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: secondaryText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Field 1: First Name
                      _buildLabel("First Name"),
                      _buildTextField(
                        controller: _firstNameController,
                        hintText: "Enter your first name",
                        icon: Icons.person_outline,
                        validator: (value) => value == null || value.trim().isEmpty ? 'First name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Field 2: Last Name
                      _buildLabel("Last Name"),
                      _buildTextField(
                        controller: _lastNameController,
                        hintText: "Enter your last name",
                        icon: Icons.badge_outlined,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Last name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Field 3: Email
                      _buildLabel("Email"),
                      if (_registrationError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            _registrationError!,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: errorColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      _buildTextField(
                        controller: _emailController,
                        hintText: "Enter your email address",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 4: Password
                      _buildLabel("Password"),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: "Create a strong password",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: secondaryText,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 6) return 'At least 6 characters required';
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: secondaryText, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              "At least 6 characters required",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Field 5: Education Level
                      _buildLabel("Education Level"),
                      GestureDetector(
                        onTap: _showEducationBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.school_outlined, color: secondaryText, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedEducation,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: mainText,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: secondaryText, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Create Account Button
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryMint, primaryContainer],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: primaryMint.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitForm,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: bgColor, strokeWidth: 2),
                                )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: bgColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: bgColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer and Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignInScreen()),
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: primaryMint,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Security Reassurance
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, color: primaryMint, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Your information is protected.",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: mainText,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        color: mainText,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: secondaryText,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: secondaryText, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
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
    );
  }
}
