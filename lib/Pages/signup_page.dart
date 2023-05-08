import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:JobFair/Pages/student_Homepage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:JobFair/textField/reuse_widget.dart';
import '../employer_widgets/EditProfilePage.dart';
import '../jobseeker_widgets/EditProfileJS.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _companyName = TextEditingController();
  TextEditingController _description = TextEditingController();
  late String _selectedRole;

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
                  Color.fromARGB(255, 251, 248, 250),
                  Color.fromARGB(255, 251, 248, 250),
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
                  reuseWidget("Enter email-Id", Icons.mail_outline, false,
                      _emailController),
                  const SizedBox(height: 15),
                  reuseWidget("Enter Password", Icons.lock_outline, true,
                      _passwordController),
                  const SizedBox(height: 15),
                  reuseWidget("Enter Phone Number", Icons.phone, false,
                      _phoneNumberController),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        color:
                            Color.fromARGB(255, 56, 163, 235).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Select your role',
                          prefixIcon: Icon(Icons.person),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                        items: <String>['Recruiter', 'Student']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? 'Please select your role' : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  reuseButton(context, false, () async {
                    if (_userNameController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _passwordController.text.isEmpty ||
                        _phoneNumberController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all the fields')),
                      );
                      return;
                    }
                    try {
                      final UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      if (userCredential.user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential.user?.uid)
                            .set({
                          'name': _userNameController.text,
                          'email': _emailController.text,
                          'phone': _phoneNumberController.text,
                          'role': _selectedRole,
                          'skills': [],
                          'createdAt': DateTime.now(),
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _selectedRole == 'Recruiter'
                                ? EditProfilePage(
                                    companyName: '',
                                    companyDescription: '',
                                    employerName: _userNameController.text,
                                    emailAddress: _emailController.text,
                                    phoneNumber: _phoneNumberController.text,
                                    mailingAddress: '',
                                    updateProfile: (String companyName,
                                        String companyDescription,
                                        String employerName,
                                        String emailAddress,
                                        String phoneNumber,
                                        String mailingAddress) {},
                                  )
                                : EEditProfilePage(
                                    name: '',
                                    email: '',
                                    highestQualification: '',
                                    location: '',
                                    phone: '',
                                    skills: [],
                                    specialization: '',
                                    updateProfile: (String name,
                                        String email,
                                        String phone,
                                        String location,
                                        String highestQualification,
                                        String specialization,
                                        List<String> skills) {},
                                  ),
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  })
                ],
              ),
            ))));
  }
}
