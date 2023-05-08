import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SidebarMenu.dart';

class EmployerPage extends StatefulWidget {
  @override
  _EmployerPageState createState() => _EmployerPageState();
}

class _EmployerPageState extends State<EmployerPage> {
  int _enrolledJobFairs = 0;
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employer Dashboard'),
      ),
      drawer: SidebarMenu(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Dashboard',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('job_postings')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return CircularProgressIndicator();
                          default:
                            _enrolledJobFairs = snapshot.data!.docs.length;
                            return Text(
                                'Enrolled job fairs: $_enrolledJobFairs');
                        }
                      },
                    ),
                    SizedBox(height: 5),
                    Text('Notifications: ${_notifications ? 'On' : 'Off'}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
