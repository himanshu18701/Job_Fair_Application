import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:JobFair/employer_widgets/employer_page.dart';

class EditProfilePage extends StatefulWidget {
  final String companyName;
  final String companyDescription;
  final String employerName;
  final String emailAddress;
  final String phoneNumber;
  final String mailingAddress;
  final Function updateProfile;

  EditProfilePage({
    required this.companyName,
    required this.companyDescription,
    required this.employerName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.mailingAddress,
    required this.updateProfile,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _companyNameController;
  late TextEditingController _companyDescriptionController;
  late TextEditingController _employerNameController;
  late TextEditingController _emailAddressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _mailingAddressController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.companyName);
    _companyDescriptionController =
        TextEditingController(text: widget.companyDescription);
    _employerNameController = TextEditingController(text: widget.employerName);
    _emailAddressController = TextEditingController(text: widget.emailAddress);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
    _mailingAddressController =
        TextEditingController(text: widget.mailingAddress);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    _employerNameController.dispose();
    _emailAddressController.dispose();
    _phoneNumberController.dispose();
    _mailingAddressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'companyName': _companyNameController.text,
      'companyDescription': _companyDescriptionController.text,
      'employerName': _employerNameController.text,
      'email': _emailAddressController.text,
      'phone': _phoneNumberController.text,
      'mailingAddress': _mailingAddressController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _updateProfile();
              widget.updateProfile(
                _companyNameController.text,
                _companyDescriptionController.text,
                _employerNameController.text,
                _emailAddressController.text,
                _phoneNumberController.text,
                _mailingAddressController.text,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployerPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            TextField(
              controller: _companyDescriptionController,
              decoration: InputDecoration(labelText: 'Company Description'),
            ),
            TextField(
              controller: _employerNameController,
              decoration: InputDecoration(labelText: 'Employer Name'),
            ),
            TextField(
              controller: _emailAddressController,
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _mailingAddressController,
              decoration: InputDecoration(labelText: 'Mailing Address'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
