import 'package:logger/logger.dart';

abstract class Loggable {
  Logger logger = Logger();

  factory Loggable._() => null;

  void i(dynamic message, [Exception error, StackTrace stacktrace]) {
    logger.i(message, error, stacktrace);
  }

  void d(dynamic message, [Exception error, StackTrace stacktrace]) {
    logger.d(message, error, stacktrace);
  }

  void w(dynamic message, [Exception error, StackTrace stacktrace]) {
    logger.w(message, error, stacktrace);
  }

  void e(dynamic message, [Exception error, StackTrace stacktrace]) {
    logger.e(message, error, stacktrace);
  }

  void log(Level level, dynamic message,
      [Exception error, StackTrace stacktrace]) {
    logger.log(level, message, error, stacktrace);
  }
}
