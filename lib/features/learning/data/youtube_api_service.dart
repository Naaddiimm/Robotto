// ---------------------------------------------------------------------------
// YouTubeApiService — wraps YouTube Data API v3 search endpoint.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_keys.dart';

class YouTubeVideoResult {
  final String videoId;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String duration; // e.g. "PT4M13S" — raw ISO 8601

  const YouTubeVideoResult({
    required this.videoId,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.duration,
  });

  /// Human-readable duration (PT4M13S → 4:13)
  String get durationLabel {
    final r = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final m = r.firstMatch(duration);
    if (m == null) return '';
    final h = int.tryParse(m.group(1) ?? '') ?? 0;
    final min = int.tryParse(m.group(2) ?? '') ?? 0;
    final sec = int.tryParse(m.group(3) ?? '') ?? 0;
    if (h > 0) return '$h:${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

class YouTubeApiService {
  static const _baseSearch = 'https://www.googleapis.com/youtube/v3/search';
  static const _baseVideos = 'https://www.googleapis.com/youtube/v3/videos';
  static const _key = ApiKeys.youTube;

  /// Search YouTube videos. Returns up to [maxResults] results.
  static Future<List<YouTubeVideoResult>> search(
    String query, {
    int maxResults = 8,
  }) async {
    if (query.trim().isEmpty) return [];

    // 1. Search for video IDs
    final searchUri = Uri.parse(_baseSearch).replace(queryParameters: {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'maxResults': '$maxResults',
      'key': _key,
    });

    final searchResp = await http.get(searchUri);
    if (searchResp.statusCode != 200) {
      throw Exception('YouTube search failed: ${searchResp.statusCode} ${searchResp.body}');
    }

    final searchJson = json.decode(searchResp.body) as Map<String, dynamic>;
    final items = (searchJson['items'] as List?) ?? [];
    if (items.isEmpty) return [];

    final ids = items
        .map((i) => i['id']?['videoId'] as String?)
        .whereType<String>()
        .toList();

    // 2. Fetch durations for those IDs
    final videosUri = Uri.parse(_baseVideos).replace(queryParameters: {
      'part': 'contentDetails,snippet',
      'id': ids.join(','),
      'key': _key,
    });

    final videosResp = await http.get(videosUri);
    if (videosResp.statusCode != 200) {
      throw Exception('YouTube videos failed: ${videosResp.statusCode}');
    }

    final videosJson = json.decode(videosResp.body) as Map<String, dynamic>;
    final videoItems = (videosJson['items'] as List?) ?? [];

    return videoItems.map((v) {
      final snippet = v['snippet'] as Map<String, dynamic>;
      final details = v['contentDetails'] as Map<String, dynamic>;
      final thumbs  = snippet['thumbnails'] as Map<String, dynamic>;
      final thumb   = (thumbs['high'] ?? thumbs['medium'] ?? thumbs['default'])
          as Map<String, dynamic>;

      return YouTubeVideoResult(
        videoId:     v['id'] as String,
        title:       snippet['title'] as String,
        channelName: snippet['channelTitle'] as String,
        thumbnailUrl: thumb['url'] as String,
        duration:    details['duration'] as String,
      );
    }).toList();
  }
}
