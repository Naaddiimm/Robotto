import 'package:flutter/material.dart';

import '../learning_theme.dart';
import '../data/learning_models.dart';
import '../widgets/youtube_player_section.dart';
import 'lesson_content_screen.dart';

class FormationDetailScreen extends StatefulWidget {
  final FormationModel formation;
  const FormationDetailScreen({super.key, required this.formation});

  @override
  State<FormationDetailScreen> createState() => _FormationDetailScreenState();
}

class _FormationDetailScreenState extends State<FormationDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final Map<int, bool> _expanded;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _expanded = {
      for (int i = 0; i < widget.formation.modules.length; i++) i: i == 0,
    };
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  FormationModel get f => widget.formation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildBanner(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildContentTab(),
                  _buildDescriptionTab(),
                  _buildInstructorTab(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LearningTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LearningTheme.border),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mes formations', style: LearningTheme.captionStyle),
              const SizedBox(height: 2),
              Text(
                f.title,
                style: const TextStyle(
                  fontFamily: LearningTheme.font,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Banner ────────────────────────────────────────────────────────────────
  Widget _buildBanner() => Container(
    width: double.infinity,
    color: const Color(0xFF050C13),
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover — YouTube intro video or placeholder
        YouTubePlayerSection(
          videoId: f.videoId,
          label: 'Vidéo de présentation',
        ),
        const SizedBox(height: 14),
        Text(f.title, style: LearningTheme.sectionStyle),
        const SizedBox(height: 4),
        Text(f.subtitle, style: LearningTheme.captionStyle),
        const SizedBox(height: 12),
        // Meta
        Row(
          children: [
            _meta(
              Icons.signal_cellular_alt_rounded,
              f.level,
              color: LearningTheme.mint,
            ),
            const SizedBox(width: 10),
            _meta(Icons.access_time_rounded, f.duration),
            const SizedBox(width: 10),
            _meta(Icons.people_rounded, '${f.enrolled} inscrits'),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: LearningTheme.star,
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  f.rating.toString(),
                  style: const TextStyle(
                    fontFamily: LearningTheme.font,
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${f.doneLessons} / ${f.totalLessons} leçons terminées',
              style: LearningTheme.captionStyle,
            ),
            Text(
              '${(f.progress * 100).round()}%',
              style: const TextStyle(
                fontFamily: LearningTheme.font,
                color: LearningTheme.mint,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: LinearProgressIndicator(
            value: f.progress,
            minHeight: 5,
            backgroundColor: LearningTheme.border,
            valueColor: const AlwaysStoppedAnimation(LearningTheme.mint),
          ),
        ),
      ],
    ),
  );

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() => Container(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: LearningTheme.border)),
    ),
    child: TabBar(
      controller: _tab,
      indicatorColor: LearningTheme.mint,
      indicatorWeight: 2,
      labelColor: LearningTheme.mint,
      unselectedLabelColor: Colors.white,
      labelStyle: const TextStyle(
        fontFamily: LearningTheme.font,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: LearningTheme.font,
        fontSize: 14,
      ),
      tabs: const [
        Tab(text: 'Contenu'),
        Tab(text: 'Description'),
        Tab(text: 'Instructeur'),
      ],
    ),
  );

  // ── Content tab ───────────────────────────────────────────────────────────
  Widget _buildContentTab() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    itemCount: f.modules.length,
    itemBuilder: (ctx, i) {
      final mod = f.modules[i];
      final open = _expanded[i] ?? false;
      return _ModuleCard(
        module: mod,
        isExpanded: open,
        onToggle: () => setState(() => _expanded[i] = !open),
        formationTitle: f.title,
      );
    },
  );

  // ── Description tab ───────────────────────────────────────────────────────
  Widget _buildDescriptionTab() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    children: [
      _secTitle('À propos de cette formation'),
      const SizedBox(height: 10),
      const Text(
        'Cette formation vous guide pas à pas dans la découverte de la '
        'plateforme Arduino. Vous apprendrez à câbler des composants '
        'électroniques, à lire des capteurs, à piloter des actionneurs '
        'et à réaliser votre premier projet embarqué de A à Z.',
        style: LearningTheme.bodyStyle,
      ),
      const SizedBox(height: 24),
      _secTitle('Ce que vous apprendrez'),
      const SizedBox(height: 10),
      ...[
        'Installer et configurer l\'environnement Arduino',
        'Lire et interpréter des données de capteurs',
        'Contrôler des actionneurs (moteurs, servos)',
        'Concevoir un projet embarqué complet',
      ].map(_bullet),
      const SizedBox(height: 24),
      _secTitle('Prérequis'),
      const SizedBox(height: 10),
      ...[
        'Notions de base en électricité',
        'Un ordinateur avec port USB',
        'Une carte Arduino (fournie ou achetée séparément)',
      ].map(_bullet),
    ],
  );

  // ── Instructor tab ────────────────────────────────────────────────────────
  Widget _buildInstructorTab() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: LearningTheme.cardDeco(),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: LearningTheme.mint.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: LearningTheme.mint.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: LearningTheme.mint,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.instructor,
                    style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Expert en systèmes embarqués',
                    style: LearningTheme.captionStyle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _meta(
                        Icons.star_rounded,
                        '4.9',
                        color: LearningTheme.star,
                      ),
                      const SizedBox(width: 8),
                      _meta(Icons.people_rounded, '3 200 étudiants'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _secTitle('Biographie'),
      const SizedBox(height: 10),
      const Text(
        'Passionné par la pédagogie, il a formé plus de 3 000 apprenants '
        'à travers ses formations en ligne et ses ateliers pratiques.',
        style: LearningTheme.bodyStyle,
      ),
    ],
  );

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: LearningTheme.border)),
    ),
    child: Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [LearningTheme.mint, LearningTheme.mintDark],
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Continuer la formation',
        style: LearningTheme.buttonStyle,
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Widget _meta(
    IconData icon,
    String text, {
    Color color = LearningTheme.textSecond,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 3),
      Text(
        text,
        style: TextStyle(
          fontFamily: LearningTheme.font,
          color: color,
          fontSize: 11,
        ),
      ),
    ],
  );

  static Widget _secTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: LearningTheme.font,
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );

  static Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(
            Icons.check_circle_rounded,
            color: LearningTheme.mint,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: LearningTheme.bodyStyle)),
      ],
    ),
  );
}

// ── Module card (expandable) ──────────────────────────────────────────────────
class _ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String formationTitle;

  const _ModuleCard({
    required this.module,
    required this.isExpanded,
    required this.onToggle,
    required this.formationTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: LearningTheme.cardDeco(
          border: isExpanded ? LearningTheme.mint : null,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: module.totalCount == 0
                                ? 0
                                : module.doneCount / module.totalCount,
                            strokeWidth: 3,
                            backgroundColor: LearningTheme.border,
                            valueColor: const AlwaysStoppedAnimation(
                              LearningTheme.mint,
                            ),
                          ),
                          Text(
                            '${module.doneCount}',
                            style: const TextStyle(
                              fontFamily: LearningTheme.font,
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: const TextStyle(
                              fontFamily: LearningTheme.font,
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${module.totalCount} leçons · ${module.totalDuration}',
                            style: LearningTheme.captionStyle,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: LearningTheme.textSecond,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    const Divider(color: LearningTheme.border, height: 1),
                    const SizedBox(height: 10),
                    ...module.lessons.map(
                      (l) =>
                          _LessonRow(lesson: l, formationTitle: formationTitle),
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

class _LessonRow extends StatelessWidget {
  final LessonModel lesson;
  final String formationTitle;
  const _LessonRow({required this.lesson, required this.formationTitle});

  @override
  Widget build(BuildContext context) {
    final active = lesson.state == LessonState.active;
    final done = lesson.state == LessonState.done;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LessonContentScreen(lesson: lesson, coursTitle: formationTitle),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? LearningTheme.mint
                    : done
                    ? LearningTheme.mint.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: (active || done)
                    ? null
                    : Border.all(color: LearningTheme.border, width: 2),
              ),
              child: Icon(
                active
                    ? Icons.play_arrow_rounded
                    : done
                    ? Icons.check
                    : null,
                size: 15,
                color: active ? LearningTheme.background : LearningTheme.mint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lesson.title,
                style: TextStyle(
                  fontFamily: LearningTheme.font,
                  color: active ? Colors.white : LearningTheme.textSecond,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Text(lesson.duration, style: LearningTheme.captionStyle),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: LearningTheme.textSecond,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
