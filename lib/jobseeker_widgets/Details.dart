import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class JobFairDetailsPage extends StatefulWidget {
  final Map<String, dynamic> jobFair;
  final bool applied;

  JobFairDetailsPage({required this.jobFair, required this.applied});

  @override
  _JobFairDetailsPageState createState() => _JobFairDetailsPageState();
}

class _JobFairDetailsPageState extends State<JobFairDetailsPage> {
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _applied = widget.applied;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobFair['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Name: ${widget.jobFair['name']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Organised By: ${widget.jobFair['organizer']}',
            ),
            SizedBox(height: 10),
            Text('Venue: ${widget.jobFair['venue']}'),
            SizedBox(height: 10),
            Text(
                'No. of Participating Job Seekers: ${widget.jobFair['numJobSeekers']}'),
            SizedBox(height: 10),
            Text(
                'Date/Time: ${widget.jobFair['date']} ${widget.jobFair['time']}'),
            SizedBox(height: 10),
            Text('Description: ${widget.jobFair['description']}'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(widget.applied ? 'Applied' : 'Apply'),
              onPressed: _applied
                  ? null
                  : () async {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        String userId = user.uid;
                        DatabaseReference databaseRef = FirebaseDatabase
                            .instance
                            .reference()
                            .child("applied_users")
                            .child(userId);

                        String jobFairName = widget.jobFair['name'];

                        databaseRef.child(jobFairName).set(true);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Applied to $jobFairName'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        setState(() {
                          _applied = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You need to sign in to apply.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
