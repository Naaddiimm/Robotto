class GithubRepo {
  final int id;
  final String fullName;
  final String name;
  final String ownerLogin;
  final String ownerAvatarUrl;
  final String description;
  final String htmlUrl;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final int openIssuesCount;
  final String? license;
  final String updatedAt;
  final bool isPrivate;
  final String? homepage;

  const GithubRepo({
    required this.id,
    required this.fullName,
    required this.name,
    required this.ownerLogin,
    required this.ownerAvatarUrl,
    required this.description,
    required this.htmlUrl,
    this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.openIssuesCount,
    this.license,
    required this.updatedAt,
    required this.isPrivate,
    this.homepage,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ownerLogin:
          (json['owner'] as Map<String, dynamic>?)?['login'] as String? ?? '',
      ownerAvatarUrl:
          (json['owner'] as Map<String, dynamic>?)?['avatar_url'] as String? ??
          '',
      description:
          json['description'] as String? ?? 'Aucune description disponible.',
      htmlUrl: json['html_url'] as String? ?? '',
      language: json['language'] as String?,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      openIssuesCount: json['open_issues_count'] as int? ?? 0,
      license:
          (json['license'] as Map<String, dynamic>?)?['spdx_id'] as String?,
      updatedAt: json['updated_at'] as String? ?? '',
      isPrivate: json['private'] as bool? ?? false,
      homepage: json['homepage'] as String?,
    );
  }

  /// Formatted relative date, e.g. "il y a 3 jours"
  String get relativeDate {
    try {
      final dt = DateTime.parse(updatedAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 365) return 'il y a ${diff.inDays ~/ 365} an(s)';
      if (diff.inDays >= 30) return 'il y a ${diff.inDays ~/ 30} mois';
      if (diff.inDays >= 1) return 'il y a ${diff.inDays} jour(s)';
      if (diff.inHours >= 1) return 'il y a ${diff.inHours}h';
      return 'il y a moins d\'1h';
    } catch (_) {
      return updatedAt;
    }
  }
}
