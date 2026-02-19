/// Konfiguracija aplikacije – API host i URL-ovi.
/// Postavi [useLocalhost] na true kada želiš koristiti lokalni API.
class AppConfig {
  /// Ručna opcija: true = localhost:5292, false = api.finbalancer.com
  static const bool useLocalhost = false;

  static String get apiHost =>
      useLocalhost ? 'http://localhost:5292' : 'https://api.finbalancer.com';
  static String get apiBaseUrl => '$apiHost/api';
}
