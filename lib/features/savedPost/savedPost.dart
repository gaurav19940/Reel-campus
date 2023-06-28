import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> savePost(String userId, String postId) async {
  try {
    final savedPostRef = _firestore.collection('users').doc(userId).collection('savedPosts');
    await savedPostRef.doc(postId).set({
      // You can add additional fields here if needed
      'postId': postId,
      'timestamp': DateTime.now(),
    });
    print('Post saved successfully!');
  } catch (e) {
    print('Failed to save post: $e');
  }
}


  /*Future<void> savePost(String postId, String userId) async {
    try {
      // Check if the post is already saved by the user
      final snapshot = await _firestore
          .collection('savedPosts')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .get();

      if (snapshot.exists) {
        // The post is already saved, you can show a message or perform an action
        print('Post is already saved.');
      } else {
        // Save the post
        await _firestore
            .collection('savedPosts')
            .doc(userId)
            .collection('posts')
            .doc(postId)
            .set({'savedAt': DateTime.now()});

        // Saving successful, you can show a success message or perform an action
        print('Post saved successfully.');
      }
    } catch (e) {
      // Handle any errors that occur during saving
      print('Error saving post: $e');
    }
  }
*/



  
// Define the data model for a saved post
/*class SavedPost {
  final String postId;
  final String userId;
  final Timestamp timestamp;

  SavedPost({
    required this.postId,
    required this.userId,
    required this.timestamp,
  });
}

// Function to save a post for a user
Future<void> savePost(String userId, String postId) async {
  final savedPostsCollection = FirebaseFirestore.instance.collection('savedPosts');

  // Create a document for the saved post with a unique ID
  final savedPostDoc = savedPostsCollection.doc();

  // Create a SavedPost object with the necessary data
  final savedPost = SavedPost(
    postId: postId,
    userId: userId,
    timestamp: Timestamp.now(),
  );

  // Save the SavedPost object to Firestore
  await savedPostDoc.set(savedPost.toJson());
}
*/




