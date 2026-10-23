import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool _googleInitialized = false;

  static const _webClientId =
      '969952473695-9laofvh0ndr4154592sq1ia7n9ihhhuf.apps.googleusercontent.com';
  static const _iosClientId =
      '969952473695-a629u7d77ramnohipcln0u6a6qbgpb6u.apps.googleusercontent.com';

  Future<User?> createAccountWithEmailAndPassword(
    String email,
    String password,
    String userName,
  ) async {
    await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((credential) async {
          await credential.user?.updateDisplayName(userName);
        });
    return firebaseAuth.currentUser;
  }

  Future<User?> loginAccountWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return firebaseAuth.currentUser;
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final credential = await firebaseAuth.signInWithPopup(
        GoogleAuthProvider(),
      );
      return credential.user;
    }

    await _ensureGoogleInitialized();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw StateError('Missing Google ID token');
      }
      final userCredential = await firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await firebaseAuth.signOut();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? _iosClientId
          : null,
      serverClientId: _webClientId,
    );
    _googleInitialized = true;
  }
}
