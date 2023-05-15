import 'package:flutter/material.dart';
import 'JobPostingPage.dart';
import 'list.dart';

class ManageJF extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Fairs'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobPostingPage(),
                  ),
                );
              },
              child: Text('Add a Job Fair'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => list(),
                  ),
                );
              },
              child: Text('View the Job Fairs'),
            ),
          ],
        ),
      ),
    );
  }
}
