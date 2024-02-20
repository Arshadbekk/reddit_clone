import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/failure.dart';
import '../../../core/utils.dart';
import '../../../models/post_model.dart';

final userCommunitiesProvider = StreamProvider((ref)  {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});


final communityControllerProvider = NotifierProvider <CommunityController, bool>(() {
  return CommunityController();
},);

final   getCommunityByNameProvider = StreamProvider.family((ref,String name)  {
  return ref.watch(communityControllerProvider.notifier).getCommunityByName(name);
});


final searchCommunityProvider = StreamProvider.family((ref ,String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final getCommunityPostsProvider = StreamProvider.family((ref,String name)  {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);

});

class CommunityController  extends Notifier<bool>{


  // CommunityController(
  //     {required CommunityRepository communityRepository, required Ref ref})

  CommunityRepository get _communityRepository=>ref.read(communtiyRepositoryProvider);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = ref.read(userProvider)?.uid??'';
    Community community = Community(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        member: [uid],
        mods: [uid]
    );
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context,l.message), (r) {
      showSnackBar(context, "community created successfully");
      Routemaster.of(context).pop();
    });
  }

  Stream <List<Community>> getUserCommunities(){
    final uid = ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<Community>getCommunityByName(String name){
    return _communityRepository.getCommunityByName(name);
  }

  StorageRepository get _storageRepository=>ref.read(storageRepositoryProvider);
  void editCommunity({
    required File? bannerFile,
    required File? profileFile,
    required BuildContext context,
    required Community community
  })async{
    state = true;
    if(profileFile!=null){
      final res = await  _storageRepository.storeFile(path: "communities/profile", id: community.name, file: profileFile);
      res.fold((l) => showSnackBar(context,l.message), (r) => community = community.copyWith(avatar:r ));
    }


    if(bannerFile != null){
      final res = await  _storageRepository.storeFile(path: "communities/banner", id: community.name, file: bannerFile);
      res.fold((l) => showSnackBar(context,l.message), (r) => community = community.copyWith(banner: r));
    }
    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context,l.message), (r) => Routemaster.of(context).pop());
  }

  Stream<List<Community>>searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }
  void joinCommunity(Community community,BuildContext context)async{
    final user = ref.read(userProvider);
   Either<Failure, void> res;
    if(community.member.contains(user?.uid)){
      res = await _communityRepository.leaveCommunity(community.name, user!.uid);
    }else{
      res = await _communityRepository.joinCommunity(community.name, user!.uid);
    }
    res.fold((l) => showSnackBar(context,l.toString()), (r) {
      if(community.member.contains(user?.uid)){
        showSnackBar(context, "community leaved");
      }else{
        showSnackBar(context, "Joined In Community");
      }
    });
  }
  void addMods(String communityName,List<String> uids,BuildContext context)async{
   final res = await _communityRepository.addMods(communityName, uids);
   res.fold((l) => showSnackBar(context,l.message), (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }

  @override
  bool build() {
    return false;

  }
}
