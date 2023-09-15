import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../constants/constants.dart';

class Authentication {
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseDb = FirebaseFirestore.instance;

  Future<User?> isUserLoggedIn() async => firebaseAuth.currentUser;

  Future<bool> isUserRegistered(String uid) async {
    return await firebaseDb
        .collection('Users')
        .doc(uid)
        .get()
        .then((doc) => doc.exists);
  }

  Future<User?> signInWithGoogle() async {
    GoogleSignIn? googleSignIn;
    if (kIsWeb) {
      googleSignIn = GoogleSignIn(
        clientId: Const.firebaseWebToken,
        scopes: [
          'email',
        ],
      );
    } else {
      googleSignIn = GoogleSignIn();
    }
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if(googleSignInAccount == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential credentials =
        await firebaseAuth.signInWithCredential(credential);
    return credentials.user;
  }

  Future<void> logout() async => await firebaseAuth.signOut();
}
