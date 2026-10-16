import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.avatarUrl,
    super.isEmailVerified,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = json['email']?.toString() ?? '';
    final rawUsername = json['username']?.toString() ?? json['name']?.toString();
    final username = (rawUsername != null && rawUsername.isNotEmpty)
        ? rawUsername
        : (email.contains('@') ? email.split('@').first : 'User');

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    return UserModel(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      email: email,
      username: username,
      avatarUrl: json['avatar_url']?.toString(),
      isEmailVerified: json['is_email_verified'] == true,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
