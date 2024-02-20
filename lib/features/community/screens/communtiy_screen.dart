import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/post_card.dart';
import '../../../main.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key,required this.name});

  void navigateToModTools(BuildContext context){
    Routemaster.of(context).push("/mod-tools/$name");
  }

  void joinCommmunity(WidgetRef ref,Community community,BuildContext context){
    ref.read(communityControllerProvider.notifier).joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user= ref.watch(userProvider);
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
          data: (community) => NestedScrollView(headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 150,
                floating: true,
                snap: true,
                flexibleSpace: Stack(
                  children: [
                    Positioned.fill(child: Image.network(community.banner,fit: BoxFit.fill,))
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Align(
                          alignment: Alignment.topLeft,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                            radius: 35,
                          ),
                        ),
                        SizedBox(
                          height: width*0.05,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("r/${community.name}",style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold
                            ),),
                            community.mods.contains(user!.uid)?
                            OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(width*0.05)
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 25)
                              ),
                                onPressed: () {
                                navigateToModTools(context);
                            }, child: Text("Mod Tools")): OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(width*0.05)
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 25)
                                ),
                                onPressed: () {
                                  joinCommmunity(ref, community, context);
                                }, child: Text(community.member.contains(user!.uid)?"Leave":"Join"))
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 10),
                        child:Text("${community.member.length} members"),
                        )
                      ]
                    )
                ),
              )
            ];
          }, body: ref.watch(getCommunityPostsProvider(name)).when(
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
          )
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => loader(),
      ),
    );
  }
}
