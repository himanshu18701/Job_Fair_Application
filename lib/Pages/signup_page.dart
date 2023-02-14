import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:job_fair/textField/reuse_widget.dart';

import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                  Color.fromARGB(255, 233, 30, 162),
                  Color.fromARGB(255, 137, 39, 176)
                ])),
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15),
                  reuseWidget("Enter UserName", Icons.person_outline, false,
                      _userNameController),
                  const SizedBox(height: 15),
                  reuseWidget("Enter email-Id", Icons.person_outline, false,
                      _emailController),
                  // const SizedBox(height: 15),
                  // reuseWidget("Enter UserName", Icons.person_outline, false,
                  //     _userNameController),
                  // const SizedBox(height: 15),
                  // reuseWidget("Enter UserName", Icons.person_outline, false,
                  //     _userNameController),
                  const SizedBox(height: 15),
                  reuseWidget("Enter Password", Icons.lock_outline, true,
                      _passwordController),
                  const SizedBox(
                    height: 15,
                  ),
                  reuseButton(context, false, () {
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text)
                        .then((value) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (constext) => HomePage()));
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                      ;
                    });
                  })
                ],
              ),
            ))));
  }
}
