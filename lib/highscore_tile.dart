import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighscoreTile extends StatelessWidget {
  final String documentId;
  final int position;
  const HighscoreTile({
    Key? key,
    required this.documentId,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the collection of highscores
    CollectionReference highscores =
        FirebaseFirestore.instance.collection('highscores');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display headings for the first record only
        if (position == 1)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'POSITION',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Text(
                  'NAME',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Text(
                  'SCORE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        // Highscore row
        FutureBuilder<DocumentSnapshot>(
          future: highscores.doc(documentId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              // Function to get the position label based on the position
              String getPositionLabel(int position) {
                switch (position) {
                  case 1:
                    return '1st';
                  case 2:
                    return '2nd';
                  case 3:
                    return '3rd';
                  case 4:
                    return '4th';
                  case 5:
                    return '5th';
                  default:
                    return position.toString() + 'th';
                }
              }

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getPositionLabel(position),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Text(data['name']),
                    SizedBox(width: 10),
                    Text(data['score'].toString()),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Loading...'),
                    SizedBox(width: 10),
                    Text(''),
                    SizedBox(width: 10),
                    Text(''),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
