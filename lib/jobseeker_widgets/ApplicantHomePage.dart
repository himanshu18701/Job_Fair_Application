import 'package:flutter/material.dart';
import 'SidebarMenu.dart';

class ApplicantPage extends StatefulWidget {
  @override
  _ApplicantPageState createState() => _ApplicantPageState();
}

class _ApplicantPageState extends State<ApplicantPage> {
  int _enrolledJobFairs = 0;
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applicant Dashboard'),
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
                    Text('Enrolled job fairs: $_enrolledJobFairs'),
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
