import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class list extends StatefulWidget {
  @override
  _liststate createState() => _liststate();
}

class _liststate extends State<list> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('job_postings');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Fairs'),
      ),
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
                          SizedBox(width: 10),
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
