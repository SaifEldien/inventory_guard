import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'core/config/env.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppIdWeb,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        authDomain: Env.firebaseAuthDomain,
        storageBucket: Env.firebaseStorageBucket,
        measurementId: Env.firebaseMeasurementId,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppIdAndroid,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        storageBucket: Env.firebaseStorageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppIdIos,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        storageBucket: Env.firebaseStorageBucket,
        iosBundleId: Env.firebaseIosBundleId,
      );
}
