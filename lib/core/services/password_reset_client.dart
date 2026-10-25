import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/server_config.dart';

class PasswordResetClient {
  static Future<void> requestCode(String email) async {
    final url = Uri.parse(
      '${ServerConfig.baseUrl}/auth/password-reset/request',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final error = _parseError(response.body);
      throw Exception(error ?? 'Failed to request reset code.');
    }
  }

  static Future<String> verifyCode(String email, String code) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/auth/password-reset/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reset_token'];
    } else {
      final error = _parseError(response.body);
      throw Exception(error ?? 'Invalid verification code.');
    }
  }

  static Future<void> confirmReset(
    String resetToken,
    String newPassword,
  ) async {
    final url = Uri.parse(
      '${ServerConfig.baseUrl}/auth/password-reset/confirm',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reset_token': resetToken,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = _parseError(response.body);
      throw Exception(error ?? 'Failed to authorize reset.');
    }
  }

  static String? _parseError(String body) {
    try {
      final data = jsonDecode(body);
      return data['detail'];
    } catch (_) {
      return null;
    }
  }
}
