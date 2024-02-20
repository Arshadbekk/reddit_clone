import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_clone/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_clone/features/home/drawers/profile_drawer.dart';
import 'package:reddit_clone/theme/pallete.dart';

import '../../../core/constants/constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}
  class _HomeScreenState extends ConsumerState<HomeScreen>{
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
  void onPageChanged(int page){
    setState(() {
      _page = page;
    });
  }

  @override

  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final userData = ref.watch(userProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: false,
        leading: Builder(
            builder: (context) {
              return InkWell(
                  onTap: () => displayDrawer(context),
                  child: Icon(Icons.menu));
            }
        ),
        actions: [
          IconButton(onPressed: () {
            showSearch(
                context: context, delegate: SearchCommunityDelegate(ref));
          }, icon: Icon(Icons.search)),
          Builder(
              builder: (context) {
                return IconButton(
                  icon: CircleAvatar(
                    backgroundImage: NetworkImage(userData.profilePic),
                  ),
                  onPressed: () {
                    displayEndDrawer(context);
                  },
                );
              }
          )
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: CommunityListDrawer(),
      endDrawer: ProfileDrawer(),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.backgroundColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Add Post"
          ),
        ],
        onTap: onPageChanged,
        currentIndex: _page,

      ),
    );
  }

}

