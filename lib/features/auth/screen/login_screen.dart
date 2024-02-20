import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/sign_in_button.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';

import '../../../core/constants/constants.dart';
import '../../../main.dart';

class loginScreen extends ConsumerWidget {
  const loginScreen({super.key});



  @override
  Widget build(BuildContext context,WidgetRef ref ) {
    final isLoading = ref.watch(authControllerProvider);
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          Constants.logoPath,
          height: width*0.12,
        ),
      ),
      body: isLoading?loader(): Column(
        children: [
          SizedBox(
            height: height*0.0408,
          ),
          Text("Dive into anything",style: TextStyle(
            fontSize: width*0.0672,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
          ),),
          SizedBox(
            height: height*0.0408,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(Constants.loginEmotePath,),
          ),
          SizedBox(
            height: height*0.0272,
          ),
          signInButton(),
        ],
      ),
    );
  }
}
