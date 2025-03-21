import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/utils/global_variables.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  bool isShowUsers = false;
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search for a user',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: mobileBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (String value) {
              if (value.trim().isNotEmpty) {
                setState(() {
                  isShowUsers = true;
                });
              }
            }),
      ),
      body: isShowUsers
          ? StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                final searchText = searchController.text.trim().toLowerCase();

                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (!data.containsKey('username') ||
                      data['username'] == null) {
                    return false;
                  }

                  final username =
                      data['username'].toString().trim().toLowerCase();

                  // Số ký tự tối thiểu cần nhập để tìm thấy username
                  int minLengthRequired =
                      (username.replaceAll(' ', '').length / 2).ceil();

                  // Kiểm tra nếu người dùng nhập đủ số ký tự yêu cầu
                  return searchText.length >= minLengthRequired &&
                      username.contains(searchText);
                }).toList();

                return ListView.builder(
                  itemCount: users.isEmpty ? 1 : users.length,
                  itemBuilder: (context, index) {
                    if (users.isEmpty) {
                      return const Center(
                        child: Text(
                          "No users found.",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final user = users[index].data() as Map<String, dynamic>;
                    return InkWell(
                      onTap: () {
                        if (user['uid'] != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(uid: user['uid']),
                            ),
                          );
                        }
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user['photoUrl'] ?? '',
                          ),
                          radius: 16,
                        ),
                        title: Text(
                          user['username'] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                return StaggeredGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: (snapshot.data! as dynamic)
                      .docs
                      .asMap()
                      .entries
                      .map<Widget>((entry) {
                    int index = entry.key;
                    var doc = entry.value;

                    return StaggeredGridTile.count(
                      crossAxisCellCount:
                          MediaQuery.of(context).size.width > webScreenSize
                              ? (index % 7 == 0 ? 3 : 2)
                              : (index % 7 == 0 ? 2 : 1),
                      mainAxisCellCount:
                          MediaQuery.of(context).size.width > webScreenSize
                              ? (index % 7 == 0 ? 3 : 2)
                              : (index % 7 == 0 ? 2 : 1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          doc['postUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
