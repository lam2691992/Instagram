import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isAnimating = false;
  late List likes; // Lưu trạng thái "like"

  @override
  void initState() {
    super.initState();
    likes = List.from(
        widget.snap['likes'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final User? user = userProvider.getUser;

    if (user == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['profilePic']),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '${widget.snap['name']}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text: widget.snap['text'],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        widget.snap['datePublished'].toDate(),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          LikeAnimation(
            isAnimating: isAnimating,
            smallLike: true,
            child: IconButton(
              onPressed: () async {
                setState(() {
                  isAnimating = true;

                  if (likes.contains(user.uid)) {
                    likes.remove(user.uid);
                  } else {
                    likes.add(user.uid);
                  }
                });

                await FirestoreMethods().likeComment(
                  widget.snap['postId'],
                  widget.snap['commentId'],
                  user.uid,
                  likes,
                );

                setState(() {
                  isAnimating = false;
                });
              },
              icon: likes.contains(user.uid)
                  ? const Icon(Icons.favorite, color: Colors.red, size: 16)
                  : const Icon(Icons.favorite_border, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
