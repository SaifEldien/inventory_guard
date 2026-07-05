import 'env.dart';

enum BackendType { firebase, api }

class AppConfig {
  // Simply change this to switch the entire backend
  static const BackendType activeBackend = BackendType.firebase;

  static String get apiBaseUrl => Env.apiBaseUrl;
}
