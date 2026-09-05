import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_role.dart';

const _sessionKey = 'almoutawa_session_v1';

class SessionCache {
  SessionCache(this._storage);

  final FlutterSecureStorage _storage;

  Future<UserSession?> read() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserSession(
        userId: json['userId'] as String,
        profileId: json['profileId'] as String? ?? '',
        displayName: json['displayName'] as String,
        role: UserRole.fromDbValue(json['role'] as String),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> write(UserSession session) async {
    final payload = jsonEncode({
      'userId': session.userId,
      'profileId': session.profileId,
      'displayName': session.displayName,
      'role': session.role.dbValue,
    });
    await _storage.write(key: _sessionKey, value: payload);
  }

  Future<void> clear() async {
    await _storage.delete(key: _sessionKey);
  }
}
