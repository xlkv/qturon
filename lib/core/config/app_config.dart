class AppConfig {
  AppConfig._();

  static const String yandexMapsApiKey = String.fromEnvironment(
    'YANDEX_MAPS_API_KEY',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'turon-suv-dev',
  );

  static const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: false,
  );

  static const String emulatorHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '127.0.0.1',
  );
}
