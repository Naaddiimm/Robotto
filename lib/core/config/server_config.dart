class ServerConfig {
  ServerConfig._();

  // The base URL for the Python FastAPI backend.
  // For Android emulator pointing to host PC, use 10.0.2.2.
  // When running on physical device, replace with the LAN IPv4 address (e.g. 192.168.x.x)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.5:8000',
  );
}
