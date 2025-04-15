import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
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
    appBar: AppBar(
      backgroundColor: mobileBackgroundColor,
      centerTitle: false,
      title: SvgPicture.asset(
        'assets/ic_instagram.svg',
        height: 32,
        colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
      ),
      actions: [
        IconButton(
          onPressed: () => navigationTapped(0),
          icon: Icon(
            Icons.home,
            color: _page == 0 ? primaryColor : secondaryColor,
          ),
        ),
        IconButton(
          onPressed: () => navigationTapped(1),
          icon: Icon(
            Icons.search,
            color: _page == 1 ? primaryColor : secondaryColor,
          ),
        ),
        IconButton(
          onPressed: () => navigationTapped(2),
          icon: Icon(
            Icons.add_a_photo,
            color: _page == 2 ? primaryColor : secondaryColor,
          ),
        ),
        IconButton(
          onPressed: () => navigationTapped(3),
          icon: Icon(
            Icons.favorite,
            color: _page == 3 ? primaryColor : secondaryColor,
          ),
        ),
        IconButton(
          onPressed: () => navigationTapped(4),
          icon: Icon(
            Icons.person,
            color: _page == 4 ? primaryColor : secondaryColor,
          ),
        ),
      ],
    ),
    body: PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      onPageChanged: onPageChanged,
      children: homeScreenItems,
    ),
  );
}
}
