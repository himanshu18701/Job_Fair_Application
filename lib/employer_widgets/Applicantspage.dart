import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ApplicantsListPage.dart';
import 'SidebarMenu.dart';

class ApplicantsPage extends StatefulWidget {
  @override
  _ApplicantsPageState createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final CollectionReference _jobFairCollection =
      FirebaseFirestore.instance.collection('job_postings');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isRecruiter = false;

  String? _jobFairId;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String? userRole = await fetchUserRole(user.uid);
      setState(() {
        _isRecruiter = userRole == 'Recruiter';
      });
    }
  }

  Future<String?> fetchUserRole(String userId) async {
    DocumentSnapshot userSnapshot = await _usersCollection.doc(userId).get();
    return (userSnapshot.data() as Map<String, dynamic>)['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Fairs'),
      ),
      drawer: SidebarMenu(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _jobFairCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Failed to load job postings.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Map<String, dynamic>> _jobFairs = [];

          if (snapshot.data != null) {
            snapshot.data!.docs.forEach((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              _jobFairs.add({
                'id': document.id,
                'name': data['location'],
                'location': data['location'],
                'date': data['dateAndTime'],
                'details': data['additionalInformation'],
              });
            });
          }

          return ListView.builder(
            itemCount: _jobFairs.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _jobFairId = _jobFairs[index]['id'];
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _jobFairs[index]['name'] ?? 'N/A',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 10),
                        Text(
                            'Location: ${_jobFairs[index]['location'] ?? 'N/A'}'),
                        SizedBox(height: 5),
                        Text('Date: ${_jobFairs[index]['date'] ?? 'N/A'}'),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            _isRecruiter
                                ? TextButton(
                                    child: Text('View Applicants'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplicantsListPage(
                                            jobFairId: _jobFairs[index]['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
