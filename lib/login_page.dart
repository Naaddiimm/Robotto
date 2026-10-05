import 'package:flutter/material.dart';

void main() {
  runApp(const StaticLoginApp());
}

class StaticLoginApp extends StatelessWidget {
  const StaticLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Static Login',
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFF8FF);
    const orange = Color(0xFFFF7043);
    const red = Color(0xFFFF3D3D);
    const borderColor = Color(0xFFC9C1C9);
    const textColor = Color(0xFF333333);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 35),

                // Movie clapperboard icon
                Center(
                  child: Icon(
                    Icons.movie,
                    size: 105,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 15),

                // Email
                SizedBox(
                  height: 36,
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'email',
                      hintStyle: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBDB8BD),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Password
                SizedBox(
                  height: 36,
                  child: TextField(
                    enabled: false,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'password',
                      hintStyle: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBDB8BD),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // SIGN IN button
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
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // CREATE ACCOUNT button
                SizedBox(
                  width: double.infinity,
                  height: 26,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      disabledBackgroundColor: red,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'CREATE AN ACCOUNT',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF555055),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '→',
                        style: TextStyle(
                          fontSize: 22,
                          color: orange,
                          height: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
