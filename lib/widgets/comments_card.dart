import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> snap; // Chuyển snap thành Map để sửa đổi được
  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isAnimating = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final User? user = userProvider.getUser;

    if (user == null) {
      return const SizedBox(); // Tránh lỗi nếu user chưa tải xong
    }

    // Đảm bảo widget.snap['likes'] không null
    List likes = widget.snap['likes'] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              widget.snap['profilePic'],
            ),
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
                  // Tạo bản sao danh sách likes để cập nhật
                  List updatedLikes = List.from(likes);
                  if (updatedLikes.contains(user.uid)) {
                    updatedLikes.remove(user.uid);
                  } else {
                    updatedLikes.add(user.uid);
                  }
                  widget.snap['likes'] = updatedLikes; // Cập nhật snap
                });

                await FirestoreMethods().likePost(
                  widget.snap['postId'],
                  user.uid,
                  widget.snap['likes'], // Đảm bảo không null
                );

                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    isAnimating = false;
                  });
                });
              },
              icon: likes.contains(user.uid) // Kiểm tra trên danh sách đã xử lý
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red, // Icon đổi màu đỏ khi đã like
                      size: 16,
                    )
                  : const Icon(
                      Icons.favorite_border,
                      size: 16,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
