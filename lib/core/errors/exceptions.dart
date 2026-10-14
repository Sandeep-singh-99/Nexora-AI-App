class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ServerException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException: $message';
}

class SensitiveDataException implements Exception {
  final String message;
  final Map<String, dynamic> piiDetails;

  SensitiveDataException(this.message, {required this.piiDetails});

  @override
  String toString() => 'SensitiveDataException: $message';
}

class QuotaExceededException implements Exception {
  final String message;
  QuotaExceededException([this.message = 'AI model quota exceeded. Switch model or provide custom BYOK key.']);

  @override
  String toString() => 'QuotaExceededException: $message';
}
