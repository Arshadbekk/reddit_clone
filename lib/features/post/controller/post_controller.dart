import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/repository/post_repository.dart';
import 'package:reddit_clone/features/user_profile/controllers/user_profile_controller.dart';
import 'package:reddit_clone/models/comment_model.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';

final postControllerProvider = NotifierProvider<PostController, bool>(
  () {
    return PostController();
  },
);

final userPostProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchCommentPosts(postId);
});

class PostController extends Notifier<bool> {
  PostRepository get _postRepository => ref.read(postRepositoryProvider);
  StorageRepository get _storageRepository =>
      ref.read(storageRepositoryProvider);

  void shareTextPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String description}) async {
    state = true;
    String postId = Uuid().v1();
    final user = ref.read(userProvider);
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user.uid,
        type: "text",
        createdAt: DateTime.now(),
        awards: [],
        description: description);

    final res = await _postRepository.addPost(post);

    ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Posted successfully");
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String link}) async {
    state = true;
    String postId = Uuid().v1();
    final user = ref.read(userProvider);
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user.uid,
        type: "link",
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);
    ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);

    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Posted successfully");
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required File? file}) async {
    state = true;
    String postId = Uuid().v1();
    final user = ref.read(userProvider);
    final imageRes = await _storageRepository.storeFile(
        path: "post/${selectedCommunity.name}", id: postId, file: file);

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user!.name,
          uid: user.uid,
          type: "image",
          createdAt: DateTime.now(),
          awards: [],
          link: r);
      final res = await _postRepository.addPost(post);
      ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);

      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, "Posted successfully");
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(Post post) async {
    final res = await _postRepository.deletePost(post);
    ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);

    res.fold((l) => null, (r) => null);
  }

  void upVote(Post post) async {
    final uid = ref.read(userProvider)!.uid;
    _postRepository.upVote(post, uid);
  }

  void downVote(Post post) async {
    final uid = ref.read(userProvider)!.uid;
    _postRepository.downVote(post, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment(
      {required BuildContext context,
      required String text,
      required Post post}) async {
    String commentId = Uuid().v1();
    final user = ref.read(userProvider)!;
    Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user.name,
        profilePic: user.profilePic);
    final res = await _postRepository.addComment(comment);
    ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);

    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  void awardPost(
      {required Post post,
      required String award,
      required BuildContext context}) async{
    final user = ref.read(userProvider);
    final res = await _postRepository.awardPost(post, award, user!.uid);
    res.fold((l) => showSnackBar(context,l.message), (r) {
      ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.awardPost);
      ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Comment>> fetchCommentPosts(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  @override
  build() {
    return false;
    // TODO: implement build
  }
}
