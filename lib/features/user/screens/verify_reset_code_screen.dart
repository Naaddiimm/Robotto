import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/password_reset_client.dart';
import 'reset_password_screen.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;
  const VerifyResetCodeScreen({super.key, required this.email});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    8,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(8, (_) => FocusNode());

  bool _isVerifying = false;
  String? _errorMessage;
  int _resendCooldown = 60;
  Timer? _resendTimer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCooldown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
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

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _onPaste(String text) {
    text = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (text.isEmpty) return;

    for (int i = 0; i < 8 && i < text.length; i++) {
      _controllers[i].text = text[i];
    }
    _hideErrorBanner();

    if (text.length >= 8) {
      _focusNodes[7].requestFocus();
      _handleVerifyCode();
    } else {
      _focusNodes[text.length].requestFocus();
    }
  }

  void _onChanged(String value, int index) {
    _hideErrorBanner();

    // Handle paste inside a single box
    if (value.length > 1) {
      _onPaste(value);
      return;
    }

    if (value.isNotEmpty) {
      _controllers[index].text = value.toUpperCase();
      if (index < 7) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _handleVerifyCode();
      }
    }
  }

  Future<void> _handleVerifyCode() async {
    final code = _getCode();
    if (code.length < 8) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final resetToken = await PasswordResetClient.verifyCode(
        widget.email,
        code,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResetPasswordScreen(email: widget.email, resetToken: resetToken),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        _showErrorBanner(e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await PasswordResetClient.requestCode(widget.email);
      if (!mounted) return;

      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A new verification code has been sent.',
            style: TextStyle(fontFamily: AppTheme.font),
          ),
          backgroundColor: AppTheme.accent,
        ),
      );

      _startResendTimer();
    } catch (e) {
      if (mounted) {
        _showErrorBanner(e.toString().replaceAll("Exception: ", ""));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Verify Code')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Enter Verification Code",
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTheme.bodyStyle,
                  children: [
                    const TextSpan(text: "We've sent an 8-character code to "),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    const TextSpan(text: ". Please enter it below."),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontFamily: AppTheme.font,
                            color: AppTheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 8 Boxes Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(8, (index) {
                  final isError = _errorMessage != null;
                  return SizedBox(
                    width: 36,
                    height: 52,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey.keyLabel == 'Backspace' &&
                            _controllers[index].text.isEmpty &&
                            index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                        ],
                        style: const TextStyle(
                          fontFamily: AppTheme.font,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceHigh,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isError ? AppTheme.error : AppTheme.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.accent,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onChanged(value, index),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isVerifying ? null : _handleVerifyCode,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.bg,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Verify Code',
                          style: AppTheme.buttonLargeStyle,
                        ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: AppTheme.bodyStyle,
                  ),
                  _resendCooldown > 0
                      ? Text(
                          "Resend in ${_resendCooldown}s",
                          style: const TextStyle(
                            fontFamily: AppTheme.font,
                            color: AppTheme.textDisabled,
                            fontSize: 14,
                          ),
                        )
                      : GestureDetector(
                          onTap: _isResending ? null : _handleResendCode,
                          child: _isResending
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.accent,
                                  ),
                                )
                              : const Text(
                                  "Resend Now",
                                  style: TextStyle(
                                    fontFamily: AppTheme.font,
                                    color: AppTheme.accent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
