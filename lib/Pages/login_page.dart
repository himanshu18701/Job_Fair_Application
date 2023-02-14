import 'package:flutter/material.dart';
import 'package:job_fair/Pages/home_page.dart';
import 'package:job_fair/Pages/signup_page.dart';
import 'package:job_fair/textField/reuse_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  reuseWidget("Enter UserName", Icons.person_outline, false,
                      _emailController),
                  SizedBox(
                    height: 20,
                  ),
                  reuseWidget("Enter Password", Icons.lock_outline, true,
                      _passwordController),
                  SizedBox(
                    height: 20,
                  ),
                  reuseButton(context, true, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }),
                  signUpOp()
                ],
              ))),
    ));
  }

  Row signUpOp() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Don't have an account ? ",
          style: TextStyle(color: Color.fromARGB(255, 16, 16, 16))),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUpPage()));
        },
        child: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
    ]);
  }
}
