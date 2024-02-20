import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/theme/pallete.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../main.dart';

class signInButton extends ConsumerWidget {
  const signInButton({super.key});

  void  signinWithGoogle(BuildContext context,WidgetRef ref){
    ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
          onPressed: () =>  signinWithGoogle(context, ref),
          icon: Image.asset(Constants.googlePath,width: width*0.098,),
        label: Text("Continue with google",style: TextStyle(
          fontSize: width*0.0504
        ),
        ),style:ElevatedButton.styleFrom(
        backgroundColor: Pallete.greyColor,
          minimumSize: Size(double.infinity,height*0.068),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width*0.056)
        )
      )
      ),
    );
  }
}
