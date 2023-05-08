import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SidebarMenu.dart';
import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? companyName;
  String? companyDescription;
  String? employerName;
  String? emailAddress;
  String? phoneNumber;
  String? mailingAddress;

  Future<void> _fetchProfileData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        companyName = doc.get('companyName') ?? '';
        companyDescription = doc.get('companyDescription') ?? '';
        employerName = doc.get('name');
        emailAddress = doc.get('email');
        phoneNumber = doc.get('phone');
        mailingAddress = doc.get('mailingAddress') ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _updateProfile(
      String companyName,
      String companyDescription,
      String employerName,
      String emailAddress,
      String phoneNumber,
      String mailingAddress) {
    setState(() {
      this.companyName = companyName;
      this.companyDescription = companyDescription;
      this.employerName = employerName;
      this.emailAddress = emailAddress;
      this.phoneNumber = phoneNumber;
      this.mailingAddress = mailingAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Profile'),
      ),
      drawer: SidebarMenu(),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          SizedBox(
            height: 120,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.business,
                    size: 80.0,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        companyName ?? '',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        companyDescription ?? '',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 8.0),
          Text(employerName ?? ''),
          Text(emailAddress ?? ''),
          Text(phoneNumber ?? ''),
          Text(mailingAddress ?? ''),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    companyName: companyName ?? '',
                    companyDescription: companyDescription ?? '',
                    employerName: employerName ?? '',
                    emailAddress: emailAddress ?? '',
                    phoneNumber: phoneNumber ?? '',
                    mailingAddress: mailingAddress ?? '',
                    updateProfile: (String companyName,
                        String companyDescription,
                        String employerName,
                        String emailAddress,
                        String phoneNumber,
                        String mailingAddress) {
                      _updateProfile(
                          companyName,
                          companyDescription,
                          employerName,
                          emailAddress,
                          phoneNumber,
                          mailingAddress);
                      _firestore
                          .collection('users')
                          .doc(_auth.currentUser?.uid)
                          .update({
                        'companyName': companyName,
                        'companyDescription': companyDescription,
                        'name': employerName,
                        'email': emailAddress,
                        'phone': phoneNumber,
                        'mailingAddress': mailingAddress,
                      });
                    },
                  ),
                ),
              );
            },
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}
