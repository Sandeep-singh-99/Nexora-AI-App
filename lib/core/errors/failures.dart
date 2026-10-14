import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  const Failure(this.message, {this.statusCode, this.errorData});

  @override
  List<Object?> get props => [message, statusCode, errorData];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode, super.errorData});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure(super.message);
}

class SensitiveDataFailure extends Failure {
  final Map<String, dynamic> piiDetails;
  const SensitiveDataFailure(super.message, {required this.piiDetails});

  @override
  List<Object?> get props => [message, piiDetails];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
