import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isLoading = false;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          userData = null; // Xóa dữ liệu cũ
        });
        getData();
      }
    });

    getData();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _clearState();
      _loadData();
    }
  }

  void _clearState() {
    if (mounted) {
      setState(() {
        userData = null;
        postLen = 0;
        followers = 0;
        following = 0;
        isFollowing = false;
      });
    }
  }

  void _loadData() {
    if (widget.uid.isNotEmpty) {
      getData();
    }
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      if (!mounted) return;

      setState(() {
        postLen = postSnap.docs.length;
        followers = userSnap.data()?['followers']?.length ?? 0;
        following = userSnap.data()?['following']?.length ?? 0;
        isFollowing =
            userSnap.data()?['followers']?.contains(currentUid) ?? false;
        userData = userSnap.data();
      });
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : Scaffold(
            appBar: AppBar(
              title: Text(
                userData != null ? userData!['username'] : "Loading...",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
            ),
            body: userData == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      (userData?['photoUrl'] != null &&
                                              userData!['photoUrl'].isNotEmpty)
                                          ? NetworkImage(userData!['photoUrl'])
                                          : const AssetImage(
                                                  'assets/default_avatar.png')
                                              as ImageProvider,
                                  radius: 40,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          buildStatColumn(postLen, 'Posts'),
                                          buildStatColumn(
                                              followers, 'Followers'),
                                          buildStatColumn(
                                              following, 'Following'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          FirebaseAuth.instance.currentUser
                                                      ?.uid ==
                                                  widget.uid
                                              ? FollowButton(
                                                  backgroundColor:
                                                      mobileBackgroundColor,
                                                  borderColor: Colors.grey,
                                                  text: 'Sign Out',
                                                  textColor: primaryColor,
                                                  function: () async {
                                                    await AuthMethods()
                                                        .signOut(context);

                                                    setState(() {
                                                      userData = null;
                                                      postLen = 0;
                                                      followers = 0;
                                                      following = 0;
                                                      isFollowing = false;
                                                    });

                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginScreen()),
                                                    );
                                                  })
                                              : isFollowing
                                                  ? FollowButton(
                                                      backgroundColor:
                                                          Colors.white,
                                                      borderColor: Colors.black,
                                                      text: 'Unfollow',
                                                      textColor: Colors.grey,
                                                      function: () async {
                                                        await FirestoreMethods()
                                                            .followUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          widget.uid,
                                                        );
                                                        setState(() {
                                                          isFollowing = false;
                                                          followers--;
                                                        });
                                                      },
                                                    )
                                                  : FollowButton(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      borderColor: Colors.white,
                                                      text: 'Follow',
                                                      textColor: Colors.white,
                                                      function: () async {
                                                        await FirestoreMethods()
                                                            .followUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          widget.uid,
                                                        );
                                                        setState(() {
                                                          isFollowing = true;
                                                          followers++;
                                                        });
                                                      },
                                                    )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                userData?['username'] ?? 'No username',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(userData?['bio'] ?? ''),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('posts')
                            .where('uid', isEqualTo: widget.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.red)),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text("No posts available"));
                          }

                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: StaggeredGrid.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              children: snapshot.data!.docs
                                  .asMap()
                                  .entries
                                  .map<Widget>((entry) {
                                int index = entry.key;
                                var doc = entry.value;

                                return StaggeredGridTile.count(
                                  crossAxisCellCount: index % 7 == 0 ? 2 : 1,
                                  mainAxisCellCount: index % 7 == 0 ? 2 : 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      doc['postUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error,
                                              color: Colors.red),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            num.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
      ],
    );
  }
}
