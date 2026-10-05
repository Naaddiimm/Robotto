import 'package:flutter/material.dart';

void main() {
  runApp(const StaticSignUpApp());
}

class StaticSignUpApp extends StatelessWidget {
  const StaticSignUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const SignUpPage(),
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFF8FF);
    const orange = Color(0xFFFF7043);
    const borderColor = Color(0xFFC9C1C9);

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

                const SizedBox(height: 35),

                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 15),

                const _StaticTextField(
                  hint: 'username',
                ),

                const SizedBox(height: 11),

                const _StaticTextField(
                  hint: 'email',
                ),

                const SizedBox(height: 11),

                const _StaticTextField(
                  hint: 'password',
                ),

                const SizedBox(height: 12),

                // Already have an account?
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Already have an account ?',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF555055),
                        ),
                      ),
                      SizedBox(width: 9),
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

                const SizedBox(height: 18),

                // Sign Up button
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
                      'SIGN UP',
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
      ),
    );
  }
}

class _StaticTextField extends StatelessWidget {
  final String hint;

  const _StaticTextField({
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
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
