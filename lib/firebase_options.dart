import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDEUn-7TwXdEin6QenCRKogLqTLjeNCZOY',
    appId: '1:332468819428:web:9110472f29700ed55fe3f1',
    messagingSenderId: '332468819428',
    projectId: 'contacts-ivykids',
    authDomain: 'contacts-ivykids.firebaseapp.com',
    storageBucket: 'contacts-ivykids.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuGrfMglhz-X3nm2T6fsBROX9ONs0dyAc',
    appId: '1:332468819428:android:6906bc17d74d70c75fe3f1',
    messagingSenderId: '332468819428',
    projectId: 'contacts-ivykids',
    storageBucket: 'contacts-ivykids.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDp354xPajCsCjSL88EjCD5J4bF01d-VuY',
    appId: '1:332468819428:ios:6b5625043862c7475fe3f1',
    messagingSenderId: '332468819428',
    projectId: 'contacts-ivykids',
    storageBucket: 'contacts-ivykids.appspot.com',
    iosClientId:
        '332468819428-gkrkeg8p0032cq2911t4bu1r7v7nugnn.apps.googleusercontent.com',
    iosBundleId: 'com.example.contacts',
  );
}
