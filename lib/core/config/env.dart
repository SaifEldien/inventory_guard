import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get firebaseApiKey => _get('FIREBASE_API_KEY');
  static String get firebaseAppIdWeb => _get('FIREBASE_APP_ID_WEB');
  static String get firebaseAppIdAndroid => _get('FIREBASE_APP_ID_ANDROID');
  static String get firebaseAppIdIos => _get('FIREBASE_APP_ID_IOS');
  static String get firebaseMessagingSenderId => _get('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseProjectId => _get('FIREBASE_PROJECT_ID');
  static String get firebaseAuthDomain => _get('FIREBASE_AUTH_DOMAIN');
  static String get firebaseStorageBucket => _get('FIREBASE_STORAGE_BUCKET');
  static String get firebaseMeasurementId => _get('FIREBASE_MEASUREMENT_ID');
  static String get firebaseIosBundleId => _get('FIREBASE_IOS_BUNDLE_ID');
  static String get apiBaseUrl => _get('API_BASE_URL');

  static String _get(String key) {
    return dotenv.env[key] ?? '';
  }
}
