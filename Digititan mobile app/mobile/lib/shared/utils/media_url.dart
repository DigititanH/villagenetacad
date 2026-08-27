import '../config/app_config.dart';

/// Resolves product image paths from the API (absolute or /uploads/...).
String? resolveMediaUrl(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  final base = AppConfig.apiBaseUrl.trim().isNotEmpty
      ? AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '')
      : 'https://villagenetacad.co.za';
  if (value.startsWith('/')) return '$base$value';
  return '$base/$value';
}
