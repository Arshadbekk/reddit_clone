import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/repository/auth_repository.dart';

import '../../../models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = NotifierProvider<AuthController, bool>(
    () {
      return AuthController();
    });

final authStateChangeProvider = StreamProvider((ref)  {
    final authController = ref.watch(authControllerProvider.notifier);
    return authController.authStateChange;
  
});


final getUserDataProvider = StreamProvider.family((ref, String uid)  {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends Notifier<bool> {

  // AuthController({required AuthRepository authRepository, required Ref ref})
     AuthRepository get _authRepository=>ref.read(authRepostioryProvider);
  //loading

  Stream<User?> get authStateChange {
    return _authRepository.authStateChange;
  }

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    user.fold((l) {
      showSnackBar(context, l.message);
    },
        (userModel) =>
            ref.read(userProvider.notifier).update((state) => userModel));
  }

  Stream<UserModel> getUserData(String uid){
    return _authRepository.getUserData(uid);
  }

  @override
  bool build() {
    return false;
  }
  void logOut(){
    _authRepository.logOut();
  }
}


