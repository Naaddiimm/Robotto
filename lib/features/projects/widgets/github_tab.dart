import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/audio_helper.dart';
import '../models/github_repo.dart';
import '../services/github_service.dart';

class GithubTab extends StatefulWidget {
  /// Optional: pre-fill the search with the project's category keywords.
  final String? initialQuery;

  const GithubTab({super.key, this.initialQuery});

  @override
  State<GithubTab> createState() => _GithubTabState();
}

class _GithubTabState extends State<GithubTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  List<GithubRepo> _repos = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  String _activeFilter = '🤖 Robotique';
  String _sortBy = 'stars';
  int _page = 1;
  bool _hasMore = true;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    // Auto-search with project category or default
    final q = widget.initialQuery?.isNotEmpty == true
        ? widget.initialQuery!
        : 'robotics robot';
    _searchCtrl.text = q;
    _search(q);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  // ─── SEARCH ────────────────────────────────────────────────────────────────

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _repos = [];
      _page = 1;
      _hasMore = true;
      _lastQuery = query.trim();
    });
    try {
      final results = await GithubService.searchRepos(
        query: query.trim(),
        sort: _sortBy,
        perPage: 20,
        page: 1,
      );
      if (mounted) {
        setState(() {
          _repos = results;
          _loading = false;
          _hasMore = results.length == 20;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final more = await GithubService.searchRepos(
        query: _lastQuery,
        sort: _sortBy,
        perPage: 20,
        page: _page + 1,
      );
      if (mounted) {
        setState(() {
          _page++;
          _repos.addAll(more);
          _hasMore = more.length == 20;
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _applyFilter(Map<String, String> topic) {
    AudioHelper.playClickSound();
    setState(() => _activeFilter = topic['label']!);
    _searchCtrl.text = topic['query']!;
    _search(topic['query']!);
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        _buildSortRow(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  // ─── SEARCH BAR ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                AudioHelper.playClickSound();
                _search(v);
              },
              decoration: InputDecoration(
                hintText: 'Rechercher sur GitHub...',
                hintStyle: GoogleFonts.poppins(
                  color: AppTheme.textDisabled,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.accent,
                  size: 20,
                ),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF1E2942)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF1E2942)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.accent,
                    width: 1.5,
                  ),
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: AppTheme.textDisabled,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              AudioHelper.playClickSound();
              _search(_searchCtrl.text);
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.bg,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FILTER CHIPS ────────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: GithubService.roboticsTopics.length,
        separatorBuilder: (_, child) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = GithubService.roboticsTopics[i];
          final isActive = _activeFilter == t['label'];
          return GestureDetector(
            onTap: () => _applyFilter(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accent : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppTheme.accent : const Color(0xFF1E2942),
                ),
              ),
              child: Text(
                t['label']!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppTheme.bg : AppTheme.textSoft,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── SORT ROW ────────────────────────────────────────────────────────────────

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const Icon(
              Icons.filter_list_rounded,
              size: 16,
              color: AppTheme.textSoft,
            ),
            const SizedBox(width: 6),
            Text(
              'Trier par :',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSoft,
              ),
            ),
            const SizedBox(width: 8),
            ...['stars', 'forks', 'updated'].map((s) {
              final labels = {
                'stars': '⭐ Étoiles',
                'forks': '🍴 Forks',
                'updated': '🕐 Récents',
              };
              final isActive = _sortBy == s;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () {
                    if (_sortBy != s) {
                      AudioHelper.playClickSound();
                      setState(() => _sortBy = s);
                      _search(
                        _lastQuery.isNotEmpty ? _lastQuery : _searchCtrl.text,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.accent.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? AppTheme.accent
                            : const Color(0xFF1E2942),
                      ),
                    ),
                    child: Text(
                      labels[s]!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive ? AppTheme.accent : AppTheme.textSoft,
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (_repos.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                '${_repos.length} résultat(s)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textDisabled,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── BODY ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 52,
                color: Color(0xFF1E2942),
              ),
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSoft,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Réessayer',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: () => _search(
                  _lastQuery.isNotEmpty ? _lastQuery : _searchCtrl.text,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_repos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.code_off_rounded,
              size: 52,
              color: Color(0xFF1E2942),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun dépôt trouvé',
              style: GoogleFonts.poppins(
                color: AppTheme.textSoft,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Modifiez votre recherche.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF4B5563),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _repos.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _repos.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 2,
              ),
            ),
          );
        }
        return _RepoCard(
          repo: _repos[index],
          onTap: () => _showRepoDetail(_repos[index]),
        );
      },
    );
  }

  // ─── REPO DETAIL BOTTOM SHEET ───────────────────────────────────────────────

  void _showRepoDetail(GithubRepo repo) {
    AudioHelper.playClickSound();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) =>
            _RepoDetailSheet(repo: repo, scrollController: controller),
      ),
    );
  }
}

// ─── REPO CARD ───────────────────────────────────────────────────────────────

class _RepoCard extends StatelessWidget {
  final GithubRepo repo;
  final VoidCallback onTap;

  const _RepoCard({required this.repo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E2942)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Owner + Repo name ──
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: repo.ownerAvatarUrl.isNotEmpty
                      ? NetworkImage(repo.ownerAvatarUrl)
                      : null,
                  backgroundColor: AppTheme.bg,
                  child: repo.ownerAvatarUrl.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: AppTheme.textSoft,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        repo.relativeDate,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
                if (repo.language != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _langColor(repo.language!).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      repo.language!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _langColor(repo.language!),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Description ──
            if (repo.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                repo.description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSoft,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Stats ──
            const SizedBox(height: 10),
            Row(
              children: [
                _Stat(
                  icon: Icons.star_rounded,
                  color: Colors.amber,
                  value: _formatCount(repo.stargazersCount),
                ),
                const SizedBox(width: 14),
                _Stat(
                  icon: Icons.fork_right_rounded,
                  color: AppTheme.accent,
                  value: _formatCount(repo.forksCount),
                ),
                const SizedBox(width: 14),
                _Stat(
                  icon: Icons.bug_report_rounded,
                  color: Colors.redAccent,
                  value: _formatCount(repo.openIssuesCount),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.textDisabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  static Color _langColor(String lang) {
    const map = <String, Color>{
      'Python': Colors.blue,
      'C++': Colors.indigo,
      'C': Color(0xFF555555),
      'Dart': Color(0xFF00B4D8),
      'JavaScript': Colors.amber,
      'TypeScript': Color(0xFF3178C6),
      'Java': Colors.orange,
      'Rust': Colors.deepOrange,
      'Go': Colors.teal,
      'Kotlin': Colors.purple,
      'Swift': Colors.red,
      'Shell': Colors.green,
    };
    return map[lang] ?? AppTheme.accent;
  }
}

// ─── STAT WIDGET ─────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;

  const _Stat({required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSoft),
        ),
      ],
    );
  }
}

// ─── REPO DETAIL SHEET ───────────────────────────────────────────────────────

class _RepoDetailSheet extends StatelessWidget {
  final GithubRepo repo;
  final ScrollController scrollController;

  const _RepoDetailSheet({required this.repo, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2942),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Header ──
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: repo.ownerAvatarUrl.isNotEmpty
                    ? NetworkImage(repo.ownerAvatarUrl)
                    : null,
                backgroundColor: AppTheme.bg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repo.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Mis à jour ${repo.relativeDate}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Description ──
          if (repo.description.isNotEmpty) ...[
            Text(
              repo.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSoft,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Stats row ──
          Row(
            children: [
              _DetailStat(
                icon: Icons.star_rounded,
                color: Colors.amber,
                label: 'Étoiles',
                value: _fmt(repo.stargazersCount),
              ),
              _DetailStat(
                icon: Icons.fork_right_rounded,
                color: AppTheme.accent,
                label: 'Forks',
                value: _fmt(repo.forksCount),
              ),
              _DetailStat(
                icon: Icons.bug_report_rounded,
                color: Colors.redAccent,
                label: 'Issues',
                value: _fmt(repo.openIssuesCount),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Tags ──
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (repo.language != null)
                _Tag(
                  label: '💻 ${repo.language!}',
                  color: _RepoCard._langColor(repo.language!),
                ),
              if (repo.license != null)
                _Tag(label: '📄 ${repo.license!}', color: Colors.blueAccent),
              _Tag(
                label: repo.isPrivate ? '🔒 Privé' : '🌐 Public',
                color: repo.isPrivate ? Colors.orange : Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── URL ──
          _InfoRow(
            icon: Icons.link_rounded,
            label: 'GitHub',
            value: repo.htmlUrl,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: repo.htmlUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'URL copiée dans le presse-papier !',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.surface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          if (repo.homepage != null && repo.homepage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.public_rounded,
              label: 'Site web',
              value: repo.homepage!,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: repo.homepage!));
              },
            ),
          ],

          const SizedBox(height: 24),

          // ── Action button ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(
                'Copier le lien du dépôt',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: repo.htmlUrl));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lien copié : ${repo.htmlUrl}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: AppTheme.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _DetailStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onCopy;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2942)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label : ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSoft,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textDisabled,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              size: 14,
              color: AppTheme.textDisabled,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}
