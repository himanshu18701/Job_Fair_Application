import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'SidebarMenu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ApplicantsListPage extends StatefulWidget {
  final String jobFairId;

  ApplicantsListPage({required this.jobFairId});

  @override
  _ApplicantsListPageState createState() => _ApplicantsListPageState();
}

class _ApplicantsListPageState extends State<ApplicantsListPage> {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final DatabaseReference _jobPostingsRef =
      FirebaseDatabase.instance.reference().child('applied_users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // print('Job fair ID: ${widget.jobFairId}');
    return Scaffold(
      appBar: AppBar(
        title: Text("Applicants List"),
      ),
      drawer: SidebarMenu(),
      body: StreamBuilder<DatabaseEvent>(
        stream: _jobPostingsRef.onValue,
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Text('Failed to load applicants builder error.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          DataSnapshot dataSnapshot = snapshot.data!.snapshot;
          Map<dynamic, dynamic> appliedUsersData =
              dataSnapshot.value as Map<dynamic, dynamic>;
          print('Applied users data: $appliedUsersData');
          return FutureBuilder<List<Applicant>>(
            future: _getApplicants(appliedUsersData),
            builder: (BuildContext context,
                AsyncSnapshot<List<Applicant>> applicantsSnapshot) {
              if (applicantsSnapshot.hasData) {
                print(
                    'Number of applicants: ${applicantsSnapshot.data?.length}');
              }
              if (applicantsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (applicantsSnapshot.hasError) {
                if (applicantsSnapshot.error is FirebaseException) {
                  FirebaseException error =
                      applicantsSnapshot.error as FirebaseException;
                  if (error.code == 'permission-denied') {
                    return Text(
                        'You do not have permission to access this data.');
                  } else {
                    return Text(
                        'Failed to load applicants due to a Firebase error: ${error.message}');
                  }
                } else {
                  return Text(
                      'Failed to load applicants: ${applicantsSnapshot.error}');
                }
              }

              List<Applicant> applicants = applicantsSnapshot.data!;
              if (applicants.length == 0) {
                return Center(child: Text('No applicants found.'));
              }
              return ListView.builder(
                itemCount: applicants.length,
                itemBuilder: (BuildContext context, int index) {
                  Applicant applicant = applicants[index];
                  print('Applicant: ${applicant.name}');
                  return ListTile(
                    title: Text(applicant.name),
                    subtitle: Text(applicant.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () {
                            _downloadResume(
                                applicant.resumeUrl, applicant.name);
                          },
                        ),
                        ElevatedButton(
                          child: Text("View Details"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ApplicantDetailsPage(applicant: applicant),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      child: Text(applicant.name.substring(0, 1)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Applicant>> _getApplicants(
      Map<dynamic, dynamic> appliedUsersData) async {
    List<Applicant> applicants = [];

    for (String userId in appliedUsersData.keys) {
      // Check for the presence of widget.jobFairId in appliedUsersData[userId]
      if (appliedUsersData[userId].containsKey(widget.jobFairId) &&
          appliedUsersData[userId][widget.jobFairId]['status'] == true) {
        Map<String, dynamic>? userData = await fetchUserDetails(userId);
        print('User data: $userData');
        print('User data jobFair: ${userData?['jobFair'] ?? 'Not set'}');
        print('User data skills: ${userData?['skills'] ?? 'Not set'}');
        if (userData != null && userData['role'] == 'Student') {
          applicants.add(Applicant(
            id: userId,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            resumeUrl: userData['resume_url'] ?? '',
            special: userData['specialization'] ?? '',
            skills: userData['skills'] is List<String>
                ? List<String>.from(userData['skills'])
                : [],
          ));
        }
      }
    }
    return applicants;
  }

  Future<void> _downloadResume(String resumeUrl, String fileName) async {
    try {
      // Get the directory for the Downloads folder on Android
      Directory downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = (await getExternalStorageDirectory())!;
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }
      String downloadPath = downloadsDirectory.path;

      // Download the file using Dio
      Dio dio = Dio();
      String filePath = '$downloadPath/$fileName.pdf';
      await dio.download(resumeUrl, filePath);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resume downloaded successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // Open the downloaded file using the device's default PDF viewer
      await OpenFile.open(filePath);
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download resume: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    DocumentSnapshot userSnapshot = await _usersCollection.doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>?;
  }
}

class Applicant {
  final String id;
  final String name;
  final String email;
  final String resumeUrl;
  final String special;
  final List<String> skills;

  Applicant({
    required this.id,
    required this.name,
    required this.email,
    required this.resumeUrl,
    required this.special,
    required this.skills,
  });
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerScreen({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(pdfUrl)),
      ),
    );
  }
}

void _launchResume(BuildContext context, String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFViewerScreen(pdfUrl: url),
    ),
  );
}

class ApplicantDetailsPage extends StatelessWidget {
  final Applicant applicant;

  const ApplicantDetailsPage({Key? key, required this.applicant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Name:',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: " ${applicant.name}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Email',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: " ${applicant.email}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Specialization',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: " ${applicant.special}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            // RichText(
            //   text: TextSpan(
            //     children: <TextSpan>[
            //       TextSpan(
            //         text: 'Skills:',
            //         style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 18,
            //             fontWeight: FontWeight.w600),
            //       ),
            //       TextSpan(
            //         text: " ${applicant.skills.join(", ")}",
            //         style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 18,
            //             fontWeight: FontWeight.w300),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 16),
            Text(
              "Resume:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              child: Text("View"),
              onPressed: () {
                _launchResume(context, applicant.resumeUrl);
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    // TODO: Implement accept functionality
                  },
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    // TODO: Implement reject functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
