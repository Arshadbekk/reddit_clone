import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/community_model.dart';

import '../../../models/post_model.dart';

final communtiyRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw "community name already exist!!";
      }
      return right(_communities.doc(community.name).set(community.toJson()));
    } on FirebaseException catch (e) {
      // return left(Failure(e.message!));
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    print("------------------------------------");
    print(uid);
    return _communities
        .where("member", arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromJson(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromJson(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toJson()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName,String userId)async{
    try{
        return right(_communities.doc(communityName).update({
          "member":FieldValue.arrayUnion([userId]),
        }));
    }on FirebaseException catch (e){
      throw e.message!;
    }catch (e){
        return left(Failure(e.toString()));
    }
  }
  FutureVoid leaveCommunity(String communityName,String userId)async{
    try{
      return right(_communities.doc(communityName).update({
        "member":FieldValue.arrayRemove([userId]),
      }));
    }on FirebaseException catch (e){
      throw e.message!;
    }catch (e){
      return left(Failure(e.toString()));
    }
  }


  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where("name",
            isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
            isLessThan:query.isEmpty?null: query.substring(0, query.length - 1) +
                String.fromCharCode(query.codeUnitAt(query.length - 1) + 1))
        .snapshots().map((event) {
          List<Community> communities= [];
          for (var community in event.docs){
            communities.add(Community.fromJson(community.data() as Map<String,dynamic>));
          }
          return communities;
    });
  }
  FutureVoid addMods(String communityName,List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        "mods":uids
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts
        .where("communityName", isEqualTo: name)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (event) => event.docs
          .map(
            (e) => Post.fromJson(e.data() as Map<String, dynamic>),
      )
          .toList(),
    );
  }

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
