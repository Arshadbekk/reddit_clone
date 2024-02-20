import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/auth/repository/auth_repository.dart';
import 'package:reddit_clone/features/user_profile/screens/user_profile_screen.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../../main.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});
  void logOut(WidgetRef ref){
    ref.read(authControllerProvider.notifier).logOut();
  }
  void navigateToUserProfile(BuildContext context,String uid){
  Routemaster.of(context).push("u/$uid");
  }

  void toggleTheme(WidgetRef ref){
    ref.read(themeNotifierProvider.notifier).toggleTheme();

  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            SizedBox(
              height: width*0.03,
            ),
            Text("u/${user.name}",style: TextStyle(
              fontSize: width*0.06,
              fontWeight: FontWeight.w500
            ),),
            SizedBox(
              height: width*0.03,
            ),
            Divider(),
            ListTile(
              leading: IconButton(icon: Icon(Icons.person),onPressed: () {
                navigateToUserProfile(context, user.uid);
              },),
              title: Text("My profile"),
            ),
            GestureDetector(
              onTap: () {
                logOut(ref);
              },
              child: ListTile(
                leading:  Icon(Icons.logout,color: Pallete.redColor,),


                title: Text("Log out"),
              ),
            ),
            Switch.adaptive(value: ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark,
              onChanged: (value) => toggleTheme(ref),)
          ],
        ),
      ),
    );
  }
}
