class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({String message = 'Network error occurred', int? statusCode})
      : super(message: message, statusCode: statusCode);
}

class ServerException extends AppException {
  ServerException({String message = 'Server error occurred', int? statusCode})
      : super(message: message, statusCode: statusCode);
}

class CacheException extends AppException {
  CacheException({String message = 'Cache error occurred'})
      : super(message: message);
}

class NotFoundException extends AppException {
  NotFoundException({String message = 'Resource not found'})
      : super(message: message, statusCode: 404);
}
