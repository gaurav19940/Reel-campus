import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randomy/core/common/error_text.dart';
import 'package:randomy/core/common/loader.dart';
import 'package:randomy/core/constants/constants.dart';
import 'package:randomy/features/auth/controlller/auth_controller.dart';
import 'package:randomy/features/community/controller/community_controller.dart';
import 'package:randomy/features/post/controller/post_controller.dart';
import 'package:randomy/models/post_model.dart';
import 'package:randomy/responsive/responsive.dart';
import 'package:randomy/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  

 /* Future<void> savePost(String userId, String postId) async {
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
}*/

Future<void> savePost(String postId, String userId) async {
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

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref.read(postControllerProvider.notifier).awardPost(post: post, award: award, context: context);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    final currentTheme = ref.watch(themeNotifierProvider);

    return Responsive(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kIsWeb)
                  Column(
                    children: [
                      IconButton(
                        onPressed: isGuest ? () {} : () => upvotePost(ref),
                        icon: Icon(
                          Constants.up,
                          size: 30,
                          color: post.upvotes.contains(user.uid) ? Pallete.redColor : null,
                        ),
                      ),
                      Text(
                        '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                        style: const TextStyle(fontSize: 17),
                      ),
                      IconButton(
                        onPressed: isGuest ? () {} : () => downvotePost(ref),
                        icon: Icon(
                          Constants.down,
                          size: 30,
                          color: post.downvotes.contains(user.uid) ? Pallete.blueColor : null,
                        ),
                      ),
                    ],
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ).copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToCommunity(context),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          post.communityProfilePic,
                                        ),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'r/${post.communityName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => navigateToUser(context),
                                            child: Text(
                                              'u/${post.username}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(onPressed: () => savePost(
                                  user.uid, post.id), 
                                  icon: Icon(Icons.save)),
                                if (post.uid == user.uid)
                                  IconButton(
                                    onPressed: () => deletePost(ref, context),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Pallete.redColor,
                                    ),
                                  ),
                              ],
                            ),
                            if (post.awards.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final award = post.awards[index];
                                    return Image.asset(
                                      Constants.awards[award]!,
                                      height: 23,
                                    );
                                  },
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: AnyLinkPreview(
                                  displayDirection: UIDirection.uiDirectionHorizontal,
                                  link: post.link!,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!kIsWeb)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: isGuest ? () {} : () => upvotePost(ref),
                                        icon: Icon(
                                          Constants.up,
                                          size: 30,
                                          color: post.upvotes.contains(user.uid) ? Pallete.redColor : null,
                                        ),
                                      ),
                                      Text(
                                        '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                      IconButton(
                                        onPressed: isGuest ? () {} : () => downvotePost(ref),
                                        icon: Icon(
                                          Constants.down,
                                          size: 30,
                                          color: post.downvotes.contains(user.uid) ? Pallete.blueColor : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => navigateToComments(context),
                                      icon: const Icon(
                                        Icons.comment,
                                      ),
                                    ),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                ref.watch(getCommunityByNameProvider(post.communityName)).when(
                                      data: (data) {
                                        if (data.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: () => deletePost(ref, context),
                                            icon: const Icon(
                                              Icons.admin_panel_settings,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                      error: (error, stackTrace) => ErrorText(
                                        error: error.toString(),
                                      ),
                                      loading: () => const Loader(),
                                    ),
                                IconButton(
                                  onPressed: isGuest
                                      ? () {}
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                  ),
                                                  itemCount: user.awards.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    final award = user.awards[index];

                                                    return GestureDetector(
                                                      onTap: () => awardPost(ref, award, context),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset(Constants.awards[award]!),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                  icon: const Icon(Icons.card_giftcard_outlined),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
