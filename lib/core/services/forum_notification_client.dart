import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';

class ForumNotificationClient {
  static Future<void> sendReplyNotification({
    required String recipientEmail,
    required String recipientFirstName,
    required String postTitle,
    required String replyAuthorName,
    required String replyPreview,
  }) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/forum/notifications/reply');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recipient_email': recipientEmail,
        'recipient_first_name': recipientFirstName,
        'post_title': postTitle,
        'reply_author_name': replyAuthorName,
        'reply_preview': replyPreview,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification.');
    }
  }
}
