import '../../shared/config/app_config.dart';

/// Maps raw HTTP/socket errors into short UI messages.
String friendlyApiError(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('connection refused') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection timed out') ||
      lower.contains('timed out')) {
    final base = AppConfig.apiBaseUrl.trim().isEmpty
        ? 'API'
        : AppConfig.apiBaseUrl.trim();
    return 'Cannot reach API at $base — start the backend '
        '(npm run dev:backend) and keep it running on port 5000.';
  }
  return raw.replaceFirst('Exception: ', '').replaceFirst('ClientException: ', '');
}
