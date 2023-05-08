import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'EditProfileJS.dart';
import 'SidebarMenu.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? name;
  String? email;
  String? phone;
  String? location;
  String? highestQualification;
  String? specialization;
  List<String>? skills;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          name = doc.get('name') ?? '';
          email = doc.get('email') ?? '';
          phone = doc.get('phone') ?? '';
          location = doc.get('location') ?? '';
          highestQualification = doc.get('highest qualification') ?? '';
          skills = List<String>.from(doc.get('skills') ?? []);
          specialization = doc.get('specialization') ?? '';
        });
      }

      // Print fetched data for debugging
      print('Fetched data:');
      print('Name: $name');
      print('Email: $email');
      print('Phone: $phone');
      print('Location: $location');
      print('Highest Qualification: $highestQualification');
      print('Specialization: $specialization');
      print('Skills: $skills');
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  void updateProfile(String name, String email, String phone, String location,
      String highestQualification, String specialization, List<String> skills) {
    setState(() {
      this.name = name;
      this.email = email;
      this.phone = phone;
      this.location = location;
      this.highestQualification = highestQualification;
      this.specialization = specialization;
      this.skills = skills;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      drawer: SidebarMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Text('Name: $name', style: TextStyle(fontSize: 18)),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            Text('Phone: $phone', style: TextStyle(fontSize: 18)),
            Text('Location: $location', style: TextStyle(fontSize: 18)),
            SizedBox(height: 32),
            Text(
              'Education',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text('Highest Qualification: $highestQualification',
                style: TextStyle(fontSize: 18)),
            Text('Specialization: $specialization',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 32),
            Text(
              'Skills: $skills',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EEditProfilePage(
                      name: name ?? '',
                      email: email ?? '',
                      phone: phone ?? '',
                      location: location ?? '',
                      highestQualification: highestQualification ?? '',
                      specialization: specialization ?? '',
                      skills: skills ?? [],
                      updateProfile: updateProfile,
                    ),
                  ),
                );
              },
              child: Text('Edit Profile'),
            )
          ],
        ),
      ),
    );
  }
}
