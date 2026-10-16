import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_ai_app/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('handles standard backend payload with null refresh_token and partial user fields', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'developer@nexora.ai',
        'created_at': '2026-10-16T11:00:00Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(user.email, 'developer@nexora.ai');
      expect(user.username, 'developer');
      expect(user.avatarUrl, isNull);
      expect(user.isEmailVerified, isFalse);
      expect(user.createdAt, isNotNull);
    });

    test('handles null and missing created_at and username gracefully', () {
      final json = <String, dynamic>{
        'user_id': 'u_42',
        'email': 'alice@example.com',
        'created_at': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'u_42');
      expect(user.email, 'alice@example.com');
      expect(user.username, 'alice');
      expect(user.createdAt, isNull);
    });
  });
}
