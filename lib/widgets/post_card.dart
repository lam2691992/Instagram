import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  final VoidCallback? onHidePost; // Callback để ẩn bài viết

  const PostCard({super.key, required this.snap, this.onHidePost});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isAnimating = false;
  bool isLikeAnimating = false;
  bool isBookmarked = false;
  double bookmarkScale = 1.0;
  // int commentLen = 0;

  // @override
  // void initState() {
  //   getComments();
  //   super.initState();
  // }

  Stream<int> getCommentStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final User? user = userProvider.getUser;
    final width = MediaQuery.of(context).size.width;

    if (user == null) {
      return const SizedBox();
    }

    bool isOwner = user.uid == widget.snap['uid'];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.snap['profImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.snap['username'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          isOwner ? "" : "Hide",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          isOwner ? "Action" : "",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        actions: [
                          if (isOwner)
                            TextButton(
                              onPressed: () async {
                                await FirestoreMethods()
                                    .deletePost(widget.snap['postId']);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onHidePost?.call(); // hide the post
                            },
                            child: const Text("Hide this post",
                                style: TextStyle(color: Colors.blue)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap['postId'],
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(widget.snap['postUrl'],
                      fit: BoxFit.fitWidth),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 120),
                  ),
                ),
              ],
            ),
          ),
          // Like, Comment, Share
          Row(
            children: [
              LikeAnimation(
                isAnimating: isAnimating,
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      isAnimating = true;
                    });

                    await FirestoreMethods().likePost(
                      widget.snap['postId'],
                      user.uid,
                      widget.snap['likes'],
                    );

                    DocumentSnapshot postSnap = await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.snap['postId'])
                        .get();

                    setState(() {
                      widget.snap['likes'] = List.from(postSnap['likes']);
                      isAnimating = false;
                    });
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(Icons.favorite_border),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => CommentsScreen(snap: widget.snap)),
                ),
                icon: const Icon(Icons.comment),
              ),
              IconButton(
                onPressed: () {
                  Share.share(
                      "📷${widget.snap['description']}\n🔗 ${widget.snap['postUrl']}");
                },
                icon: const Icon(Icons.send_outlined),
              ),
            ],
          ),
          // comment
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.snap['likes'].length} likes",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.w800)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: '${widget.snap['username']} ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextSpan(text: '${widget.snap['description']}'),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(snap: widget.snap),
                    ),
                  ),
                  child: StreamBuilder<int>(
                    stream: getCommentStream(),
                    builder: (context, snapshot) {
                      final commentCount = snapshot.data ?? 0;
                      return Text(
                        'View all $commentCount comments',
                        style: const TextStyle(
                            fontSize: 12, color: secondaryColor),
                      );
                    },
                  ),
                ),
                Text(
                  DateFormat.yMMMd()
                      .format(widget.snap['datePublished'].toDate()),
                  style: const TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
