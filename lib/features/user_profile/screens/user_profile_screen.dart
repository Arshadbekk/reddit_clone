import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/features/user_profile/controllers/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/common/post_card.dart';
import '../../../main.dart';
import '../../auth/controller/auth_controller.dart';
import '../../community/controller/community_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateToEditProfile(BuildContext context) {
    Routemaster.of(context).push("/edit-profile/$uid");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                              child: Image.network(
                            user.banner,
                            fit: BoxFit.fill,
                          )),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(20).copyWith(bottom: 70),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 45,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(20)
                                .copyWith(bottom: 20, left: width * 0.03),
                            child: OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            width * 0.05)),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25)),
                                onPressed: () {
                                  navigateToEditProfile(context);
                                },
                                child: Text("Edit Profile")),
                          )
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverList(
                          delegate: SliverChildListDelegate([
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "r/${user.name}",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("${user.karma} Karma"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 2,
                        )
                      ])),
                    )
                  ];
                },
                body: ref.watch(getUserPostsProvider(uid)).when(
                      data: (data) {
                        return  ListView.builder(
                          itemBuilder: (context, index) {
                            final post =data[index];
                            return PostCard(post: post);

                          },
                          itemCount: data.length,
                        );
                      },
                      error: (error, stackTrace) {
                        print(error.toString());
                        return ErrorText(error: error.toString());

                      },
                      loading: () => loader(),
                    )),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => loader(),
          ),
    );
  }
}
