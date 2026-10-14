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
    return UserModel(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
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
