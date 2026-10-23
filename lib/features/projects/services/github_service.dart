import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_repo.dart';

/// Lightweight wrapper around the GitHub REST API v3.
/// No token required for public endpoints (60 req/h unauthenticated).
class GithubService {
  static const String _base = 'https://api.github.com';

  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  // ─── SEARCH ──────────────────────────────────────────────────────────────────

  /// Search repositories by keyword.
  /// [query]   : search terms (e.g. "arduino robot")
  /// [sort]    : "stars" | "forks" | "updated" | "best-match"
  /// [perPage] : results per page (max 100)
  static Future<List<GithubRepo>> searchRepos({
    required String query,
    String sort = 'stars',
    int perPage = 20,
    int page = 1,
  }) async {
    final q = Uri.encodeQueryComponent('$query fork:true');
    final uri = Uri.parse(
      '$_base/search/repositories?q=$q&sort=$sort&order=desc&per_page=$perPage&page=$page',
    );

    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => GithubRepo.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 403) {
      throw GithubRateLimitException();
    } else {
      throw GithubApiException(
          'Erreur ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // ─── TOPIC SEARCH ────────────────────────────────────────────────────────────

  /// Search by GitHub topic (e.g. "robotics", "arduino", "ros")
  static Future<List<GithubRepo>> searchByTopic({
    required String topic,
    int perPage = 20,
    int page = 1,
  }) async {
    return searchRepos(
      query: 'topic:$topic',
      sort: 'stars',
      perPage: perPage,
      page: page,
    );
  }

  // ─── TRENDING ROBOTICS PRESETS ───────────────────────────────────────────────

  static const List<Map<String, String>> roboticsTopics = [
    {'label': '🤖 Robotique', 'query': 'robotics robot'},
    {'label': '⚡ Arduino', 'query': 'arduino robot'},
    {'label': '🍓 Raspberry Pi', 'query': 'raspberry-pi robot'},
    {'label': '🧠 ROS', 'query': 'ros2 robot'},
    {'label': '🦾 Bras robot', 'query': 'robotic arm'},
    {'label': '🚗 Autonome', 'query': 'autonomous robot'},
    {'label': '🛸 Drone', 'query': 'drone flight controller'},
    {'label': '🏭 IoT', 'query': 'iot smart robot'},
  ];
}

// ─── EXCEPTIONS ──────────────────────────────────────────────────────────────

class GithubRateLimitException implements Exception {
  @override
  String toString() =>
      'Limite de requêtes GitHub atteinte. Réessayez dans quelques minutes.';
}

class GithubApiException implements Exception {
  final String message;
  const GithubApiException(this.message);
  @override
  String toString() => message;
}
