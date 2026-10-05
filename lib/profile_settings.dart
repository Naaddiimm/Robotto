import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileSettingsApp());
}

class ProfileSettingsApp extends StatelessWidget {
  const ProfileSettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Settings',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const ProfileSettingsPage(),
    );
  }
}

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFF8FF);
    const orange = Color(0xFFFF7043);
    const borderColor = Color(0xFFC9C1C9);
    const hintColor = Color(0xFFC5BEC5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 48,
        title: const Text(
          'Profile settings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 25),

              // Profile avatar
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFB84D),
                      Color(0xFFE94C86),
                      Color(0xFF7448A8),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 58,
                  color: Color(0xFFFF5D78),
                ),
              ),

              const SizedBox(height: 38),

              // Current password
              const _StaticTextField(
                hint: 'Current password',
                height: 35,
              ),

              const SizedBox(height: 11),

              // New password
              const _StaticTextField(
                hint: 'New password',
                height: 35,
              ),

              const SizedBox(height: 11),

              // Address
              const _StaticTextField(
                hint: 'Address',
                height: 48,
              ),

              const SizedBox(height: 14),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 26,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    disabledBackgroundColor: orange,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticTextField extends StatelessWidget {
  final String hint;
  final double height;

  const _StaticTextField({
    required this.hint,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 10,
            color: Color(0xFFC5BEC5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(
              color: Color(0xFFC9C1C9),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(
              color: Color(0xFFC9C1C9),
              width: 1,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(
              color: Color(0xFFC9C1C9),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
