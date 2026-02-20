/// Konfiguracija aplikacije – API host i URL-ovi.
/// Postavi [useLocalhost] na true kada želiš koristiti lokalni API.
class AppConfig {
  /// Ručna opcija: true = localhost:5292, false = api.finbalancer.com
  static const bool useLocalhost = false;

  /// Google OAuth Web Client ID (za web). Ako je null, meta tag u index.html se koristi.
  /// Npr. "123456789-xxx.apps.googleusercontent.com" iz Google Cloud Console.
  static const String? googleWebClientId = null;

  static String get apiHost =>
      useLocalhost ? 'http://localhost:5292' : 'https://api.finbalancer.com';
  static String get apiBaseUrl => '$apiHost/api';
}
