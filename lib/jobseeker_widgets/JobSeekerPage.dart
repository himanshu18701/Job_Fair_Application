import 'package:flutter/material.dart';
import 'SidebarMenu.dart';

class JobSeekerPage extends StatefulWidget {
  @override
  _JobSeekerPageState createState() => _JobSeekerPageState();
}

class _JobSeekerPageState extends State<JobSeekerPage> {
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
