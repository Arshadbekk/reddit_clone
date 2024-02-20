import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/models/comment_model.dart';

import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_def.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;
  CollectionReference get _post =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection );

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection );

  FutureVoid addPost(Post post) async {
    try {
      return right(_post.doc(post.id).set(post.toJson()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _post
        .where("communityName",
            whereIn: communities.map((e) => e.name).toList())
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromJson(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_post.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upVote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _post.doc(post.id).update({
        "downvotes": FieldValue.arrayRemove([userId]),
      });
    }

    if (post.upvotes.contains(userId)) {
      _post.doc(post.id).update({
        "upvotes": FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.id).update({
        "upvotes": FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downVote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _post.doc(post.id).update({
        "upvotes": FieldValue.arrayRemove([userId]),
      });
    }

    if (post.downvotes.contains(userId)) {
      _post.doc(post.id).update({
        "downvotes": FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.id).update({
        "downvotes": FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<Post> getPostById(String postId) {
    return _post.doc(postId).snapshots().map(
          (event) => Post.fromJson(event.data() as Map<String, dynamic>),
        );
  }
  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toJson());
      return right(_post.doc(comment.postId).update({
        "commentCount":FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>>getCommentsOfPost(String postId){
    return _comments
        .where("postId",isEqualTo: postId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (event) => event.docs
          .map(
            (e) => Comment.fromJson(
          e.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  FutureVoid awardPost(Post post,String award,String senderId) async {
    try {
      _post.doc(post.id).update({
        "awards":FieldValue.arrayUnion([award]),
      });
      _users.doc(senderId).update({
        "awards":FieldValue.arrayRemove([award]),
      });
      return right(  _users.doc(post.uid).update({
        "awards":FieldValue.arrayUnion([award]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


}
