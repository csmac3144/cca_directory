// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cca_directory/auth.dart';

import 'package:cca_directory/login_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: MyHomePage(title: 'CCA Sign In', auth: new Auth(),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.auth, this.title}) : super(key: key);
  final AuthImpl auth;

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> _message = Future<String>.value('');
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String verificationId;
  final String testSmsCode = '888888';
  final String testPhoneNumber = '+1 408-555-6969';


  Future<String> _testSignUpWithEmail() async {
    return await widget.auth.signUp(_emailController.text, _passwordController.text);
    // try {
    //   final FirebaseUser user = await _auth.createUserWithEmailAndPassword(
    //       email: _emailController.text, password: _passwordController.text);
    //   assert(user != null);
    //   assert(!user.isAnonymous);
    //   // assert(user.isEmailVerified);
    //   assert(await user.getIdToken() != null);
    //   if (Platform.isIOS) {
    //     // Anonymous auth doesn't show up as a provider on iOS
    //     assert(user.providerData.isEmpty);
    //   } else if (Platform.isAndroid) {
    //     // Anonymous auth does show up as a provider on Android
    //     assert(user.providerData.length == 2);
    //     assert(user.providerData[0].providerId == 'firebase');
    //     assert(user.providerData[0].uid != null);
    //     assert(user.providerData[0].displayName == null);
    //     assert(user.providerData[0].photoUrl == null);
    //     assert(user.providerData[0].email != null);
    //   }
    //   final FirebaseUser currentUser = await _auth.currentUser();
    //   await currentUser.sendEmailVerification();
    //   assert(user.uid == currentUser.uid);

    //   return 'signUpWithEmail succeeded: $user';

    // } catch (e) {
    //   print(e.toString());
    //   return e.message;
    // }
  }

  Future<String> _testSignInWithEmail() async {
    return await widget.auth.signIn(_emailController.text, _passwordController.text)
      .then((onValue) {
        return onValue;
      }).catchError((e) {
      return e.message;
    });
  }

  Future<String> _testSignInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final FirebaseUser user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      return 'signInWithGoogle succeeded: $user';
      
    } catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MaterialButton(
              child: const Text('Test signInWithGoogle'),
              onPressed: () {
                setState(() {
                  _message = _testSignInWithGoogle();
                });
              }),
          MaterialButton(
              child: const Text('Test signUpWithEmail'),
              onPressed: () {
                setState(() {
                  _message = _testSignUpWithEmail();
                });
              }),
          Container(
            margin: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder()

              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder()

              ),
            ),
          ),
          MaterialButton(
              child: const Text('Test signInWithEmail'),
              onPressed: () {
                setState(() {
                  _message = _testSignInWithEmail();
                });
              }),
          FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return Text(snapshot.data ?? '',
                    style:
                        const TextStyle(color: Color.fromARGB(255, 0, 155, 0)));
              }),
        ],
      ),
    );
  }
}
