import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  // Set<String> uids = {};
  List<String> uids = [];
  int cntr = 0;

  void addUids(String uid) {
    print("add uids");
    print(uid);
    setState(() {
      uids.add(uid);
    });
  }

  void removeUids(String uid) {
    print("remove uids");
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                saveMods();
              },
              icon: Icon(Icons.done))
        ],
      ),
      body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) => ListView.builder(
                  itemCount: community.member.length,
                  itemBuilder: (BuildContext context, int index) {
                    final member = community.member[index];
                    uids=community.mods;


                    return ref.watch(getUserDataProvider(member)).when(
                          data: (user) {

                           // uids.add(community.mods[0]);
                            // cntr++;
                            return CheckboxListTile(
                              title: Text(user.name),
                              value:uids.contains(user.uid),
                              onChanged: (value) {
                                if (value!) {
                                  addUids(user.uid);
                                } else {
                                  removeUids(user.uid);
                                }
                              },
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => loader(),
                        );
                  },
                ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => loader());
      }),
    );

    // body: ref.watch(getCommunityByNameProvider(widget.name)).when(
    //     data:(community) => ListView.builder(
    //       itemCount: community.member.length,
    //       itemBuilder: (BuildContext context, int index) {
    //         final member = community.member[index];
    //         print("checkkkk");
    //         print(member);
    //         print(uids);
    //         print("checkkkk");
    //       return
    //         ref.watch(getUserDataProvider(member)).when(
    //             data: (user) {
    //               if(community.mods.contains(member) && cntr == 0){
    //                 uids.add(member);
    //               }
    //               cntr++;
    //              return CheckboxListTile(
    //                 title: Text(user.name),
    //                 value: uids.contains(user.uid),
    //                 onChanged: (value) {
    //               if(value!){
    //                 addUids(user.uid);
    //               }else{
    //                 removeUids(user.uid);
    //               }
    //                 },);
    //
    //             }   ,
    //             error:(error, stackTrace) => ErrorText(error: error.toString()),
    //             loading:  () => loader(),);
    //
    //       },
    //     ),
    //     error: (error, stackTrace) => ErrorText(error: error.toString()),
    //     loading: () => loader(),
    // ),
  }
}
