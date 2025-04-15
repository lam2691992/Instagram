import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "some error occurred while uploading";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();

      Post post = Post(
        datePublished: DateTime.now(),
        uid: uid,
        username: username,
        description: description,
        likes: [],
        postId: postId,
        postUrl: photoUrl,
        profImage: profImage,
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());

      res = 'success';
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  // like posts
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

// post comments
  Future<void> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    try {
      if (text.isEmpty) {
        print('Text is empty');
        return;
      }

      final commentId = const Uuid().v1();
      final commentsRef =
          _firestore.collection('posts').doc(postId).collection('comments');

      await _firestore.runTransaction((transaction) async {
        transaction.set(
          commentsRef.doc(commentId),
          {
            'profilePic': profilePic,
            'name': name,
            'uid': uid,
            'text': text,
            'commentId': commentId,
            'datePublished': DateTime.now(),
          },
        );

        final postRef = _firestore.collection('posts').doc(postId);
        transaction.update(postRef, {
          'commentCount': FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('[ERROR] postComment: ${e.toString()}');
      rethrow;
    }
  }

  // deleting post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(
        err.toString(),
      );
    }
  }

  // like comment

Future<void> likeComment(
  String postId,
  String commentId,
  String uid,
  List likes,
) async {
  final commentRef = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId);

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(commentRef);
      if (!snapshot.exists) throw Exception('Comment không tồn tại');

      List currentLikes = List.from(snapshot['likes'] ?? []);
      bool isLiked = currentLikes.contains(uid);

      if (isLiked) {
        currentLikes.remove(uid);
      } else {
        currentLikes.add(uid);
      }

      transaction.update(commentRef, {'likes': currentLikes});
    });
  } catch (e) {
    print('Lỗi transaction: $e');
    throw Exception('Không thể cập nhật like: ${e.toString()}');
  }
}




// follow and unfollow
  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }
}
