import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../jobseeker_widgets/Details.dart';
import 'SidebarMenu.dart';

class JobFairPage extends StatefulWidget {
  @override
  _JobFairPageState createState() => _JobFairPageState();
}

class _JobFairPageState extends State<JobFairPage> with WidgetsBindingObserver {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('job_postings');
  Map<String, Set<String>> _appliedJobFairs = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchAppliedJobFairs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchAppliedJobFairs();
    }
  }

  Future<void> _fetchAppliedJobFairs() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DatabaseReference databaseRef =
          FirebaseDatabase.instance.reference().child("applied_users");
      DataSnapshot dataSnapshot =
          (await databaseRef.child(userId).once()).snapshot;
      if (dataSnapshot.value != null) {
        Map<String, dynamic> appliedJobFairsMap =
            dataSnapshot.value as Map<String, dynamic>;
        Map<String, Set<String>> appliedJobFairs = {};
        for (String jobId in appliedJobFairsMap.keys) {
          DataSnapshot jobDataSnapshot =
              (await databaseRef.child(userId).child(jobId).once()).snapshot;
          if ((jobDataSnapshot.value as Map<String, dynamic>)['status'] ==
              true) {
            appliedJobFairs[jobId] = {userId};
          }
        }
        setState(() {
          _appliedJobFairs = appliedJobFairs;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Fairs'),
      ),
      drawer: SidebarMenu(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collectionRef.snapshots(),
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

          snapshot.data!.docs.forEach((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            _jobFairs.add({
              'id': document.id,
              'name': data['location'],
              'location': data['location'],
              'date': data['dateAndTime'],
              'details': data['additionalInformation'],
            });
          });

          return ListView.builder(
            itemCount: _jobFairs.length,
            itemBuilder: (BuildContext context, int index) {
              String jobId = _jobFairs[index]['id'];
              bool isApplied = _appliedJobFairs.containsKey(jobId) &&
                  _appliedJobFairs[jobId]!
                      .contains(FirebaseAuth.instance.currentUser?.uid ?? '');
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _jobFairs[index]['name'],
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text('Location: ${_jobFairs[index]['location']}'),
                      SizedBox(height: 5),
                      Text('Date: ${_jobFairs[index]['date']}'),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: Text('Details'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobFairDetailsPage(
                                    jobFair: _jobFairs[index],
                                    applied: isApplied,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            child: Text(isApplied ? 'Applied' : 'Apply'),
                            onPressed: isApplied
                                ? null
                                : () async {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      String userId = user.uid;
                                      DatabaseReference databaseRef =
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child("applied_users")
                                              .child(userId);
                                      DataSnapshot dataSnapshot =
                                          (await databaseRef
                                                  .child(jobId)
                                                  .once())
                                              .snapshot;
                                      if (dataSnapshot.value != null &&
                                          (dataSnapshot.value as Map<String,
                                                  dynamic>)['status'] ==
                                              true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'You have already applied to ${_jobFairs[index]['name']}'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        databaseRef.child(jobId).set({
                                          'status': true,
                                          'jobName': _jobFairs[index]['name'],
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Applied to ${_jobFairs[index]['name']}'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        setState(() {
                                          _appliedJobFairs
                                              .putIfAbsent(jobId, () => {})
                                              .add(userId);
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'You need to sign in to apply.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
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
