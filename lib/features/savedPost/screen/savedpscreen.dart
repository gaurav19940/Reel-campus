import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SavedPostsPage extends StatelessWidget {
  final List<SavedPost> savedPosts;

  const SavedPostsPage({required this.savedPosts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('savedPosts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final savedPosts = snapshot.data!.docs.map((doc) {
              final data = doc.data();
              return SavedPost(
                postId: data['postId'],
                timestamp: data['timestamp'],
              );
            }).toList();
            return ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                final savedPost = savedPosts[index];
                return ListTile(
                  title: Text(savedPost.postId),
                  subtitle: Text(savedPost.timestamp),
                  // Add more widgets to display additional information from the saved post
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
  
    );
  }

  

  
}

class SavedPost {
  final String postId;
  final String timestamp;

  SavedPost({required this.postId, required this.timestamp});
}