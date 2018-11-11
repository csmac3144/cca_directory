import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthImpl {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<String> getCurrentUser();
  Future<void> signOut();
}

class Auth implements AuthImpl {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    try {
      final FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password:  password);
      assert(user != null);
      assert(user.email != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);


      if (Platform.isIOS) {
        // Anonymous auth doesn't show up as a provider on iOS
        //assert(user.providerData.isEmpty);
      } else if (Platform.isAndroid) {
        // Anonymous auth does show up as a provider on Android
        assert(user.providerData.length == 2);
        assert(user.providerData[0].providerId == 'firebase');
        assert(user.providerData[0].uid != null);
        assert(user.providerData[0].displayName == null);
        assert(user.providerData[0].photoUrl == null);
        assert(user.providerData[0].email != null);
      }
        final FirebaseUser currentUser = await _firebaseAuth.currentUser();
        assert(user.uid == currentUser.uid);

        print('signInWithEmail succeeded: $user');
        return user.uid;

    } catch (e) {
      return e.message;
    }

    // FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    // return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    try {
      final FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      assert(user != null);
      assert(!user.isAnonymous);
      // assert(user.isEmailVerified);
      assert(await user.getIdToken() != null);
      if (Platform.isIOS) {
        // Anonymous auth doesn't show up as a provider on iOS
        assert(user.providerData.isEmpty);
      } else if (Platform.isAndroid) {
        // Anonymous auth does show up as a provider on Android
        assert(user.providerData.length == 2);
        assert(user.providerData[0].providerId == 'firebase');
        assert(user.providerData[0].uid != null);
        assert(user.providerData[0].displayName == null);
        assert(user.providerData[0].photoUrl == null);
        assert(user.providerData[0].email != null);
      }
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      await currentUser.sendEmailVerification();
      assert(user.uid == currentUser.uid);

      print('signUpWithEmail succeeded: $user');
      return currentUser.uid;

    } catch (e) {
      print(e.toString());
      return e.message;
    }

    // FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    // return user.uid;
  }

  Future<String> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}