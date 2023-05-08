import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../jobseeker_widgets/ApplicantHomePage.dart';
import 'package:JobFair/Pages/signup_page.dart';
import 'package:JobFair/textField/reuse_widget.dart';
import 'package:JobFair/Pages/admin_page.dart';
import 'package:JobFair/employer_widgets/employer_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _role;

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 251, 248, 250),
              Color.fromARGB(255, 251, 248, 250),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.295,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWid("assets/homeicon.png"),
                SizedBox(
                  height: 30,
                ),
                reuseWidget(
                  "Enter UserName",
                  Icons.person_outline,
                  false,
                  _emailController,
                ),
                SizedBox(
                  height: 30,
                ),
                reuseWidget(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordController,
                ),
                SizedBox(
                  height: 30,
                ),
                reuseButton(context, true, () async {
                  try {
                    final UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    if (userCredential.user != null) {
                      final userId = userCredential.user?.uid;
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get();
                      _role = userDoc['role'];
                      print(_role);
                      if (_role == 'Admin') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminPage(),
                          ),
                        );
                      }
                      if (_role == 'Recruiter') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployerPage(),
                          ),
                        );
                      }
                      if (_role == 'Student') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicantPage(),
                          ),
                        );
                      }
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      _showErrorSnackBar('No user found.');
                    } else if (e.code == 'wrong-password') {
                      _showErrorSnackBar(
                          'Wrong password provided for this user.');
                    }
                  }
                }),
                signUpOp(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Image logoWid(String imageico) {
    return Image.asset(
      imageico,
      fit: BoxFit.fitWidth,
      width: MediaQuery.of(context).size.height * 0.35,
      height: MediaQuery.of(context).size.height * 0.36,
    );
  }

  Row signUpOp() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Don't have an account ? ",
          style:
              TextStyle(color: Color.fromARGB(255, 16, 16, 16), fontSize: 18)),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUpPage()));
        },
        child: const Text(
          "Sign Up",
          style: TextStyle(
              color: Color.fromARGB(255, 23, 143, 241),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      )
    ]);
  }
}
