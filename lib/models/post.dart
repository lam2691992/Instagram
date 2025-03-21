import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postId;
  final String username;
  final datePublished;
  final String postUrl;
  final String profImage;
  final likes;

  const Post({
    required this.description,
    required this.uid,
    required this.postUrl,
    required this.username,
    required this.profImage,
    required this.datePublished,
    required this.postId,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'username': username,
        'uid': uid,
        'postUrl': postUrl,
        'profImage': profImage,
        'postId': postId,
        'datePublished': datePublished,
        'likes': likes,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      datePublished: snapshot['datePublished'],
      description: snapshot['description'],
      postId: snapshot['postId'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      likes: snapshot['likes'],
    );
  }
}
