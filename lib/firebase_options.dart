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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyA407OGTp-G7BgEa2XpCJr6bvS5nRPIeLA',
    appId: '1:969952473695:web:ea80424bf27eb0164ca1ea',
    messagingSenderId: '969952473695',
    projectId: 'evently-38212',
    authDomain: 'evently-38212.firebaseapp.com',
    storageBucket: 'evently-38212.firebasestorage.app',
    measurementId: 'G-ZZHM7PPVPL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzRzJJ35qi4R6dCsRDLqxlhUwwKStbeSw',
    appId: '1:969952473695:android:6fb3cba20ac9f6194ca1ea',
    messagingSenderId: '969952473695',
    projectId: 'evently-38212',
    storageBucket: 'evently-38212.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiTIoBmPiW9AeWtMMjPwAmM7SrCsQfOsc',
    appId: '1:969952473695:ios:5351a187bba45a8e4ca1ea',
    messagingSenderId: '969952473695',
    projectId: 'evently-38212',
    storageBucket: 'evently-38212.firebasestorage.app',
    iosBundleId: 'com.example.assignment6',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDiTIoBmPiW9AeWtMMjPwAmM7SrCsQfOsc',
    appId: '1:969952473695:ios:5351a187bba45a8e4ca1ea',
    messagingSenderId: '969952473695',
    projectId: 'evently-38212',
    storageBucket: 'evently-38212.firebasestorage.app',
    iosBundleId: 'com.example.assignment6',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA407OGTp-G7BgEa2XpCJr6bvS5nRPIeLA',
    appId: '1:969952473695:web:2a39c20d01fd86154ca1ea',
    messagingSenderId: '969952473695',
    projectId: 'evently-38212',
    authDomain: 'evently-38212.firebaseapp.com',
    storageBucket: 'evently-38212.firebasestorage.app',
    measurementId: 'G-DR0YF0Z11G',
  );
}
