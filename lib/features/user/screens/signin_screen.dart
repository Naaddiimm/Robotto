import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();
  
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Design system tokens based on DESIGN.md
  static const Color bgColor = AppTheme.bg;
  static const Color surfaceLow = AppTheme.surface;
  static const Color surface = AppTheme.surface;
  static const Color primaryMint = AppTheme.accent;
  static const Color primaryContainer = AppTheme.accentMid;
  static const Color mainText = AppTheme.text;
  static const Color secondaryText = AppTheme.textSoft;
  static const Color errorColor = AppTheme.error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  void _showErrorBanner(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _hideErrorBanner() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _showResetPasswordModal() {
    // Pre-fill the reset email if the user has already typed one
    _resetEmailController.text = _emailController.text;
    final GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: resetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Reset Access",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: mainText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: secondaryText),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter your registered email address to receive a reset key.",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: secondaryText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel("Transmission Address"),
                    _buildTextField(
                      controller: _resetEmailController,
                      hintText: "pilot@robotto.ai",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email is required';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildPrimaryButton(
                      text: "Transmit Reset Key",
                      onPressed: () {
                        if (resetFormKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Reset key transmitted (Prototype)",
                                style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                              ),
                              backgroundColor: primaryMint,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: secondaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitSignIn() async {
    _hideErrorBanner();
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Authenticate via DB
        await _authService.loginUser(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Show success banner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Terminal Authenticated",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: bgColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Connecting to ROBOTTO Command Grid...",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: bgColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            backgroundColor: primaryMint,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Navigate to Home Screen after authenticating
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorBanner(e.toString().replaceAll("Exception: ", ""));
        }
      }
    } else {
      _showErrorBanner("Please correct your credentials.");
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
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Error Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: errorColor.withValues(alpha: 0.1),
                            border: Border.all(color: errorColor.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: errorColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: errorColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Logo Container
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryMint.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 50,
                              errorBuilder: (context, error, stackTrace) => const Text(
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
                      
                      // Status dot under logo (like the reference)
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: 24,
                          height: 12,
                          decoration: BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: primaryMint,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Headings
                      const Text(
                        "Welcome Back!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Sign in to continue exploring the world of robotics.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: secondaryText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Field: Email
                      _buildLabel("Email Address"),
                      _buildTextField(
                        controller: _emailController,
                        hintText: "Enter your email address",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        onChanged: (_) => _hideErrorBanner(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Field: Password
                      _buildLabel("Password"),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: "Enter your password",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        onChanged: (_) => _hideErrorBanner(),
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
                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _showResetPasswordModal,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: primaryMint,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Sign In Button
                      _buildPrimaryButton(
                        text: "Sign In",
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submitSignIn,
                      ),
                      const SizedBox(height: 32),

                      // Create Account Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
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
                                MaterialPageRoute(builder: (context) => const SignupScreen()),
                              );
                            },
                            child: const Text(
                              "Create Account",
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
                      const SizedBox(height: 32),

                      // Security Footer
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, color: secondaryText, size: 14),
                          SizedBox(width: 6),
                          Text(
                            "Your robotics journey continues here.",
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
          fontSize: 14,
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
    Iterable<String>? autofillHints,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      onChanged: onChanged,
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

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: onPressed == null && !isLoading
            ? null
            : const LinearGradient(
                colors: [primaryMint, primaryContainer],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: onPressed == null && !isLoading ? surfaceLow : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed == null
            ? null
            : [
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
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: bgColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: onPressed == null ? secondaryText : bgColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: onPressed == null ? secondaryText : bgColor,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}
