import 'package:flutter/material.dart';

class ProfileContactUsScreen extends StatefulWidget {
  const ProfileContactUsScreen({super.key});

  @override
  State<ProfileContactUsScreen> createState() => _ProfileContactUsScreenState();
}

class _ProfileContactUsScreenState extends State<ProfileContactUsScreen> {
  // Cybernetic Orbit Colors
  static const Color bgColor = Color(0xFF091422);
  static const Color surface = Color(0xFF15202F);
  static const Color primaryMint = Color(0xFF85FFDE);
  static const Color mainText = Color(0xFFD8E3F7);
  static const Color secondaryText = Color(0xFFBACAC3);
  static const Color errorColor = Color(0xFFFFB4AB);

  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    // Simulate async network request
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSending = false;
        _subjectController.clear();
        _messageController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: bgColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Message sent successfully',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: bgColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: primaryMint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
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
                    "Contact Us",
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
                        "We're here to help",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: mainText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Reach out to the ROBOTTO team with your questions, feedback, or support requests.",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: secondaryText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _subjectController,
                        label: "Subject",
                        hintText: "What is this about?",
                        icon: Icons.title,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a subject' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTextField(
                        controller: _messageController,
                        label: "Message",
                        hintText: "Describe your issue or feedback in detail...",
                        icon: Icons.message_outlined,
                        maxLines: 6,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a message' : null,
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
                          onPressed: _isSending ? null : _handleSend,
                          child: _isSending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: bgColor,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Send Message',
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
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    required String? Function(String?) validator,
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
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: mainText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
            prefixIcon: maxLines == 1 
                ? Icon(icon, color: secondaryText, size: 20)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: Icon(icon, color: secondaryText, size: 20),
                  ),
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
