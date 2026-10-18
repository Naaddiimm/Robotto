import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen
import '../data/repositories/user_repository.dart';

class ProfileSetupScreen extends StatefulWidget {
  final int userId;
  final Set<String> selectedInterests;

  const ProfileSetupScreen({super.key, required this.userId, required this.selectedInterests});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // Design system tokens based on DESIGN.md
  static const Color bgColor = Color(0xFF091422);
  static const Color surfaceLow = Color(0xFF111C2B);
  static const Color surface = Color(0xFF15202F);
  static const Color surfaceHigh = Color(0xFF202B3A);
  static const Color surfaceHighest = Color(0xFF2B3545);
  static const Color primaryMint = Color(0xFF85FFDE);
  static const Color primaryContainer = Color(0xFF35E6C0);
  static const Color mainText = Color(0xFFD8E3F7);
  static const Color secondaryText = Color(0xFFBACAC3);

  String? _selectedExperience;
  final Set<String> _selectedGoals = {};
  
  final UserRepository _userRepo = UserRepository();
  bool _isSaving = false;

  final List<Map<String, dynamic>> _experienceLevels = [
    {
      "id": "beginner",
      "title": "Beginner",
      "subtitle": "I'm just getting started.",
      "icon": Icons.eco_outlined,
    },
    {
      "id": "intermediate",
      "title": "Intermediate",
      "subtitle": "I've built a few projects.",
      "icon": Icons.build_outlined,
    },
    {
      "id": "advanced",
      "title": "Advanced",
      "subtitle": "I build complex systems.",
      "icon": Icons.memory_outlined,
    },
    {
      "id": "expert",
      "title": "Expert",
      "subtitle": "Extensive robotics mastery.",
      "icon": Icons.emoji_events_outlined,
    },
  ];

  final List<String> _learningGoals = [
    "Learn Robotics Fundamentals",
    "Build My First Robot",
    "Improve Programming Skills",
    "Participate in Competitions",
    "Develop AI Projects",
    "Join a Robotics Team",
    "Build Professional Skills",
  ];

  bool get _isFormValid => _selectedExperience != null;

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _handleCompleteProfile() async {
    if (_isFormValid) {
      setState(() {
        _isSaving = true;
      });

      try {
        await _userRepo.updateExperienceLevel(widget.userId, _selectedExperience!);
        await _userRepo.replaceUserLearningGoals(widget.userId, _selectedGoals);

        if (!mounted) return;
        
        // Prototype completion action
        showDialog(
        context: context,
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
                "Profile Completed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: mainText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Your workspace is being generated based on your profile and interests.",
            textAlign: TextAlign.center,
            style: TextStyle(
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
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Enter Workspace',
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
        debugPrint("Error completing profile: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 24,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.smart_toy, color: primaryMint, size: 16,
                        ),
                      ),
                    ),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: primaryMint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: bgColor, size: 16),
                  ),
                ],
              ),
            ),

            // Progress Info Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "STEP 2 OF 2",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryMint,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: secondaryText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Profile Setup",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "100% Complete",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryMint,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Container(
              height: 4,
              width: double.infinity,
              color: surfaceHighest,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryMint,
                  boxShadow: [
                    BoxShadow(
                      color: primaryMint.withValues(alpha: 0.5),
                      blurRadius: 8,
                    )
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: surfaceHighest),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.badge_outlined, color: primaryMint, size: 14),
                          SizedBox(width: 6),
                          Text(
                            "YOUR ROBOTICS PROFILE",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryMint,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Headings
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: mainText,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: "Build Your "),
                          TextSpan(
                            text: "Robotics Profile",
                            style: TextStyle(color: primaryMint),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Tell us about your background and what you want to achieve. We'll calibrate your autonomous hardware modules and tailor tutorials specifically to you.",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: secondaryText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Smart Match Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: surfaceHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.psychology, color: primaryMint, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ROBOTTO Smart Match",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: mainText,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Customizing parts directory, simulator tools & team squads.",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // SECTION 1: Experience Level
                    _buildSectionHeader(
                      icon: Icons.bar_chart_outlined,
                      title: "Your Experience Level",
                      badgeText: "Required",
                      isBadgePrimary: false,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "How experienced are you with autonomous systems & hardware?",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.15,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _experienceLevels.length,
                      itemBuilder: (context, index) {
                        final experience = _experienceLevels[index];
                        final isSelected = _selectedExperience == experience["id"];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedExperience = experience["id"];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? surfaceHighest : surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryMint : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: surfaceHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    experience["icon"],
                                    color: isSelected ? primaryMint : secondaryText,
                                    size: 20,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      experience["title"],
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: mainText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      experience["subtitle"],
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        color: secondaryText,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // SECTION 2: Learning Goals
                    _buildSectionHeader(
                      icon: Icons.flag_outlined,
                      title: "Your Learning Goals",
                      badgeText: "Multiple choice",
                      isBadgePrimary: true,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "What would you like to achieve inside ROBOTTO?",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: _learningGoals.map((goal) {
                        final isSelected = _selectedGoals.contains(goal);
                        return GestureDetector(
                          onTap: () => _toggleGoal(goal),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? surfaceHighest : surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? primaryMint : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryMint : surfaceHighest,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  goal,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? primaryMint : mainText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: bgColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _isFormValid
                          ? const LinearGradient(
                              colors: [primaryMint, primaryContainer],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: _isFormValid ? null : surfaceLow,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _isFormValid
                          ? [
                              BoxShadow(
                                color: primaryMint.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: (_isFormValid && !_isSaving) ? _handleCompleteProfile : null,
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: bgColor, strokeWidth: 2.5),
                            )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Complete Profile',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: _isFormValid ? bgColor : secondaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward, 
                            color: _isFormValid ? bgColor : secondaryText, 
                            size: 20
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: secondaryText, size: 14),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You can freely change your telemetry & preferences anytime.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String badgeText,
    required bool isBadgePrimary,
  }) {
    return Row(
      children: [
        Icon(icon, color: primaryMint, size: 22),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: mainText,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isBadgePrimary ? surfaceHighest : surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBadgePrimary ? Colors.transparent : surfaceHighest,
            ),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isBadgePrimary ? primaryMint : secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
