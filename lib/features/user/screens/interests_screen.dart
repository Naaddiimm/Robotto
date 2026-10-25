import 'package:flutter/material.dart';

import 'profile_setup_screen.dart';
import '../../../core/data/repositories/user_repository.dart';
import '../../../core/data/models/user.dart';
import '../../../core/theme/app_theme.dart';

class InterestOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  InterestOption(this.id, this.title, this.subtitle, this.icon);
}

class InterestCategory {
  final String title;
  final IconData icon;
  final List<InterestOption> options;

  InterestCategory(this.title, this.icon, this.options);
}

class InterestsScreen extends StatefulWidget {
  final int userId;
  final User? user;

  const InterestsScreen({
    super.key,
    required this.userId,
    this.user,
  });

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final UserRepository _userRepo = UserRepository();
  bool _isSaving = false;
  // Design system tokens based on DESIGN.md
  static const Color bgColor = AppTheme.bg;
  static const Color surfaceLow = AppTheme.surface;
  static const Color surface = AppTheme.surface;
  static const Color surfaceHigh = AppTheme.surfaceHigh;
  static const Color surfaceHighest = AppTheme.surfaceTop;
  static const Color primaryMint = AppTheme.accent;
  static const Color primaryContainer = AppTheme.accentMid;
  static const Color mainText = AppTheme.text;
  static const Color secondaryText = AppTheme.textSoft;

  final Set<String> _selectedInterests = {};

  final List<InterestCategory> _categories = [
    InterestCategory("Robotics & Automation", Icons.smart_toy_outlined, [
      InterestOption(
        "combat_robotics",
        "Combat Robotics",
        "BattleBots & Arenas",
        Icons.sports_mma_outlined,
      ),
      InterestOption(
        "mobile_robotics",
        "Mobile Robotics",
        "Rovers & AGVs",
        Icons.toys_outlined,
      ),
      InterestOption(
        "humanoid_robots",
        "Humanoid Robots",
        "Bipedal Kinematics",
        Icons.accessibility_new_outlined,
      ),
      InterestOption(
        "industrial_automation",
        "Industrial Automation",
        "SCARA & 6-Axis",
        Icons.precision_manufacturing_outlined,
      ),
    ]),
    InterestCategory(
      "Electronics & Embedded Systems",
      Icons.developer_board_outlined,
      [
        InterestOption(
          "arduino_esp32",
          "Arduino & ESP32",
          "IoT & Dev Boards",
          Icons.memory_outlined,
        ),
        InterestOption(
          "sensors_actuators",
          "Sensors & Actuators",
          "IMU, LiDAR & BLDC",
          Icons.sensors_outlined,
        ),
        InterestOption(
          "embedded_systems",
          "Embedded Systems",
          "Firmware & Real-Time",
          Icons.developer_board,
        ),
        InterestOption(
          "pcb_design",
          "PCB Design",
          "Circuits & Board Layout",
          Icons.schema_outlined,
        ),
      ],
    ),
    InterestCategory("Programming & AI", Icons.psychology_outlined, [
      InterestOption(
        "ai",
        "Artificial Intelligence",
        "Intelligent Systems",
        Icons.psychology,
      ),
      InterestOption(
        "computer_vision",
        "Computer Vision",
        "Image Processing",
        Icons.visibility_outlined,
      ),
      InterestOption(
        "machine_learning",
        "Machine Learning",
        "Data-Driven Models",
        Icons.model_training_outlined,
      ),
      InterestOption(
        "ros",
        "ROS / ROS 2",
        "Robot Operating System",
        Icons.computer_outlined,
      ),
    ]),
    InterestCategory(
      "Mechanical Design & Fabrication",
      Icons.architecture_outlined,
      [
        InterestOption(
          "3d_printing",
          "3D Printing",
          "Rapid Prototyping",
          Icons.print_outlined,
        ),
        InterestOption(
          "cad_modeling",
          "CAD & 3D Modeling",
          "Digital Design",
          Icons.architecture,
        ),
        InterestOption(
          "cnc_machining",
          "CNC Machining",
          "Precision Manufacturing",
          Icons.build_circle_outlined,
        ),
        InterestOption(
          "mechanical_design",
          "Mechanical Design",
          "Gears & Mechanisms",
          Icons.settings_outlined,
        ),
      ],
    ),
    InterestCategory("Community & Activities", Icons.people_outline, [
      InterestOption(
        "competitions",
        "Competitions",
        "Challenges & Tournaments",
        Icons.emoji_events_outlined,
      ),
      InterestOption(
        "collaborative_projects",
        "Collaborative Projects",
        "Build Together",
        Icons.group_work_outlined,
      ),
      InterestOption(
        "courses",
        "Courses & Tutorials",
        "Learn New Skills",
        Icons.school_outlined,
      ),
      InterestOption(
        "marketplace",
        "Components Market",
        "Discover & Trade Parts",
        Icons.store_outlined,
      ),
    ]),
  ];

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else {
        _selectedInterests.add(id);
      }
    });
  }

  bool get _hasEnoughInterests => _selectedInterests.length >= 3;

  void _handleContinue() async {
    if (_hasEnoughInterests) {
      setState(() {
        _isSaving = true;
      });

      try {
        await _userRepo.replaceUserInterests(widget.userId, _selectedInterests);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
              userId: widget.userId,
              selectedInterests: _selectedInterests,
              user: widget.user,
            ),
          ),
        );
      } catch (e) {
        debugPrint("Error saving interests: $e");
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
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
                  Row(
                    children: [
                      const Text(
                        "STEP 1 OF 2",
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
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: primaryMint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: bgColor,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress Bar
            Container(
              height: 4,
              width: double.infinity,
              color: surfaceHighest,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5, // 50% progress
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryMint,
                    boxShadow: [
                      BoxShadow(
                        color: primaryMint.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryMint,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryMint.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "PERSONALIZE YOUR EXPERIENCE",
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
                          TextSpan(text: "What Sparks Your\n"),
                          TextSpan(
                            text: "Robotics Passion?",
                            style: TextStyle(color: primaryMint),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Choose the hardware and tech fields you love. We will customize your blueprints, courses, kits, and community feed around them.",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: secondaryText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Helper Message Pill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _hasEnoughInterests
                            ? primaryMint.withValues(alpha: 0.1)
                            : surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasEnoughInterests
                              ? primaryMint.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasEnoughInterests
                                ? Icons.check_circle
                                : Icons.bolt,
                            color: primaryMint,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  color: mainText,
                                ),
                                children: _hasEnoughInterests
                                    ? [
                                        TextSpan(text: "You've selected "),
                                        TextSpan(
                                          text:
                                              "${_selectedInterests.length} interests",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryMint,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ". Ready to proceed!",
                                        ),
                                      ]
                                    : const [
                                        TextSpan(text: "Select at least "),
                                        TextSpan(
                                          text: "3 interests",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryMint,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " to unlock your personal workspace.",
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Categories List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 32),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: surfaceHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: primaryMint,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category.title,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: mainText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.35,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: category.options.length,
                              itemBuilder: (context, optionIndex) {
                                final option = category.options[optionIndex];
                                final isSelected = _selectedInterests.contains(
                                  option.id,
                                );

                                return GestureDetector(
                                  onTap: () => _toggleInterest(option.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? surfaceHighest
                                          : surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryMint
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: surfaceHighest,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                option.icon,
                                                color: isSelected
                                                    ? primaryMint
                                                    : secondaryText,
                                                size: 20,
                                              ),
                                            ),
                                            if (isSelected)
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: surfaceHighest,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: primaryMint,
                                                  size: 14,
                                                ),
                                              )
                                            else
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: surfaceHighest,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              option.title,
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: mainText,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              option.subtitle,
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 10,
                                                color: secondaryText,
                                              ),
                                              maxLines: 1,
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
                          ],
                        );
                      },
                    ),
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
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _hasEnoughInterests
                          ? const LinearGradient(
                              colors: [primaryMint, primaryContainer],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: _hasEnoughInterests ? null : surfaceLow,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _hasEnoughInterests
                          ? [
                              BoxShadow(
                                color: primaryMint.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
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
                      onPressed: (_hasEnoughInterests && !_isSaving)
                          ? _handleContinue
                          : null,
                      child: _isSaving
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
                                  'Continue',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: _hasEnoughInterests
                                        ? bgColor
                                        : secondaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: _hasEnoughInterests
                                      ? bgColor
                                      : secondaryText,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
