import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({Key? key}) : super(key: key);

  @override
  _JobPostingPageState createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  late String dateAndTime;
  late String location;
  late String participatingCompanies;
  late String jobTypes;
  late String jobRequirements;
  late String registrationProcess;
  late String additionalInformation;
  late FirebaseFirestore _firestore;
  late CollectionReference _collectionRef;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _collectionRef = _firestore.collection('job_postings');
  }

  void _saveDetails() {
    // Implement saving of details
    _collectionRef.add({
      'dateAndTime': dateAndTime,
      'location': location,
      'jobTypes': jobTypes,
      'jobRequirements': jobRequirements,
      'additionalInformation': additionalInformation,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Job posting saved.'),
        duration: Duration(seconds: 2),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save job posting.'),
        duration: Duration(seconds: 2),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Fair Posting'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date and Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                dateAndTime = value;
              },
              decoration: InputDecoration(
                hintText: 'e.g. March 15, 2023, 10:00 AM - 4:00 PM',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                location = value;
              },
              decoration: InputDecoration(
                hintText: 'e.g. 123 Main St, Anytown USA',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Job Types',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                jobTypes = value;
              },
              decoration: InputDecoration(
                hintText: 'e.g. Full-time\nPart-time\nInternships',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Job Requirements',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                jobRequirements = value;
              },
              decoration: InputDecoration(
                hintText:
                    "e.g. Bachelor's degree in Computer Science \n2 + years of experience in software development",
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Registration Process',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                registrationProcess = value;
              },
              decoration: InputDecoration(
                hintText:
                    'e.g. Please visit our website to register for the event.',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Additional Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                additionalInformation = value;
              },
              decoration: InputDecoration(
                hintText:
                    'e.g. Dress code is business casual.\nBring copies of your resume.',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDetails,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
