import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(
          data: (data) => ref.watch(userPostProvider(data)).when(
            data: (data) {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final post =data[index];
                    return PostCard(post: post);

                  },
                itemCount: data.length,
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => loader(),),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => loader(),
        );
  }
}
