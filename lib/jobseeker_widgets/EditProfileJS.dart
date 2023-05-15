import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:JobFair/jobseeker_widgets/ApplicantHomePage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EEditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String highestQualification;
  final String specialization;
  final List<String> skills;
  final Function(String, String, String, String, String, String, List<String>)
      updateProfile;

  EEditProfilePage(
      {required this.name,
      required this.email,
      required this.phone,
      required this.location,
      required this.highestQualification,
      required this.specialization,
      required this.skills,
      required this.updateProfile});

  @override
  _EEditProfilePageState createState() => _EEditProfilePageState();
}

class _EEditProfilePageState extends State<EEditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _highestQualificationController;
  late TextEditingController _specializationController;
  late TextEditingController _skillsController;
  late List<String> _skillList = _skillsController.text
      .split(',')
      .map((skill) => skill.trim())
      .where((skill) => skill.isNotEmpty)
      .toList();
  File? _resumeFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _locationController = TextEditingController(text: widget.location);
    _highestQualificationController =
        TextEditingController(text: widget.highestQualification);
    _specializationController =
        TextEditingController(text: widget.specialization);
    _skillsController = TextEditingController(text: widget.skills.join(','));

    _skillsController.addListener(() {
      _skillList = _skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _highestQualificationController.dispose();
    _specializationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadResume(String uid) async {
    if (_resumeFile != null) {
      try {
        Reference ref =
            FirebaseStorage.instance.ref().child('resumes').child('$uid.pdf');
        await ref.putFile(_resumeFile!);
        String resumeUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'resume_url': resumeUrl,
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _updateProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameController.text,
      'location': _locationController.text,
      'highest qualification': _highestQualificationController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'specialization': _specializationController.text,
      'skills': _skillList,
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
              String uid = FirebaseAuth.instance.currentUser!.uid;
              await _uploadResume(uid);
              widget.updateProfile(
                _nameController.text,
                _emailController.text,
                _phoneController.text,
                _locationController.text,
                _highestQualificationController.text,
                _specializationController.text,
                _skillList,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApplicantPage(),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 32),
              Text(
                'Education',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _highestQualificationController,
                decoration: InputDecoration(labelText: 'Highest Qualification'),
              ),
              TextField(
                controller: _specializationController,
                decoration: InputDecoration(labelText: 'Specialization'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _skillsController,
                decoration: InputDecoration(labelText: 'Skills'),
              ),
              SizedBox(height: 32),
              Text(
                'Resume',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                _resumeFile == null
                    ? 'No resume selected'
                    : 'Selected resume: ${_resumeFile!.path.split('/').last}',
              ),
              TextButton(
                onPressed: _pickResume,
                child: Text(
                  'Select Resume (PDF)',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
