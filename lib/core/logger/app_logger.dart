import 'dart:async';
import 'package:logger/logger.dart';

class AppLogger {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  final _logController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  void info(String message) {
    _logger.i(message);
    _logController.add('[INFO] $message');
  }

  void debug(String message) {
    _logger.d(message);
    _logController.add('[DEBUG] $message');
  }

  void warning(String message) {
    _logger.w(message);
    _logController.add('[WARNING] $message');
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _logController.add('[ERROR] $message${error != null ? ': $error' : ''}');
  }

  void dispose() {
    _logController.close();
  }
}
