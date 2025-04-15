import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
Widget build(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context);
  final user = userProvider.getUser;

  if (user == null) {
    return const Center(child: CircularProgressIndicator());
  }

  final List<Widget> homeScreenItems = [
    const FeedScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const Text('notifications'),
    ProfileScreen(uid: user.uid),
  ];

  return Scaffold(
    body: PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: const NeverScrollableScrollPhysics(),
      children: homeScreenItems,
    ),
    bottomNavigationBar: CupertinoTabBar(
      backgroundColor: mobileBackgroundColor,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.home,
            color: _page == 0 ? primaryColor : secondaryColor,
          ),
          backgroundColor: primaryColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.search,
            color: _page == 1 ? primaryColor : secondaryColor,
          ),
          backgroundColor: primaryColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.add_circled,
            color: _page == 2 ? primaryColor : secondaryColor,
          ),
          backgroundColor: primaryColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.heart,
            color: _page == 3 ? primaryColor : secondaryColor,
          ),
          backgroundColor: primaryColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.person,
            color: _page == 4 ? primaryColor : secondaryColor,
          ),
          backgroundColor: primaryColor,
        ),
      ],
      onTap: navigationTapped,
    ),
  );
}

}
