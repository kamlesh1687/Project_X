import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum SignUpState { Loading, Loaded }

class SignUpViewModel extends ChangeNotifier {
/* ------------------------------ Loadingstatus ----------------------------- */

  SignUpState _signUpState = SignUpState.Loaded;
  get signUpState => _signUpState;
  set signUpState(_value) {
    _signUpState = _value;
  }

/* ------------------ Declaration of objects and variables ------------------ */

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  bool _isSignupScreen = true;

/* ------------------------------- All Getters ------------------------------ */

  get emailcontroller => _emailController;
  get usernamecontroller => _usernameController;
  get passwordcontroller => _passwordController;
  get isSignupScreen => _isSignupScreen;

/* ------------------------------- All Setters ------------------------------ */

  set isSignupScreen(value) {
    _isSignupScreen = value;
    notifyListeners();
  }

/* --------------------- Switch between login and signUp -------------------- */
  void button1function() {
    if (isSignupScreen) signupmethod();

    isSignupScreen = true;
  }

  void button2function() {
    if (!isSignupScreen) loginmethod();

    isSignupScreen = false;
  }

/* --------------------- CreateUserwithEmailAndPassword --------------------- */

  Future signupmethod() async {
    try {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailcontroller.text, password: passwordcontroller.text)
          .then((value) {
        signUpState = SignUpState.Loading;
        print('Started saving info');

        var userref = FirebaseFirestore.instance.collection('users');
        var firebaseuser = FirebaseAuth.instance.currentUser;

        addusertofirestore(firebaseuser, userref);

        emailcontroller.clear();
        passwordcontroller.clear();
        usernamecontroller.clear();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

/* ----------------------- SignInWithEmailAndPassword ----------------------- */

  void loginmethod() {
    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailcontroller.text, password: passwordcontroller.text)
          .then((value) {
        signUpState = SignUpState.Loading;
        emailcontroller.clear();
        passwordcontroller.clear();
        usernamecontroller.clear();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else if (e.code == 'Given String is empty or null') {
        print('Wrong password provided for that user.');
      }
    }
  }

/* -------------------------- Adduserdatatofirestore ------------------------ */

  Future addusertofirestore(var firebaseuser, var userref) async {
    try {
      userref.doc('${firebaseuser.uid}').set({
        'displayName': usernamecontroller.text,
        'userEmail': emailcontroller.text,
        'userDescription': "Enter Your Description",
        'userId': firebaseuser.uid,
        'photoUrl':
            "https://tribunest.com/wp-content/uploads/2019/02/dummy-profile-image.png",
      }).then((value) {
        print("Saved Successfully");
      });
    } catch (e) {
      print(e.toString());
    }
  }

/* ------------------------------ End of class ------------------------------ */

}
