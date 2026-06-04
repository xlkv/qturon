import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger() : _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final Logger _logger;

  void debug(String event, [Map<String, Object?>? data]) {
    _logger.d(_format(event, data));
  }

  void info(String event, [Map<String, Object?>? data]) {
    _logger.i(_format(event, data));
  }

  void warn(String event, [Map<String, Object?>? data, Object? error]) {
    _logger.w(_format(event, data), error: error);
  }

  void error(String event, Object error, [StackTrace? stack, Map<String, Object?>? data]) {
    _logger.e(_format(event, data), error: error, stackTrace: stack);
  }

  String _format(String event, Map<String, Object?>? data) {
    if (data == null || data.isEmpty) return event;
    return '$event $data';
  }
}

final loggerProvider = Provider<AppLogger>((ref) => AppLogger());
