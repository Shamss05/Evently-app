import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  Future<UserCredential> registerUser(
    String name,
    String email,
    String password,
  ) async {
    var userData = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userData.user?.updateDisplayName(name);
    return userData;
  }

  Future<UserCredential> login(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  }

  bool isLoggedIn() {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<void> forgetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  User? getUserData() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
