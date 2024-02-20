import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../../main.dart';

class AddPostscreen extends ConsumerWidget {
  const AddPostscreen({super.key});

  void navigateToType(BuildContext context,String type){
    Routemaster.of(context).push("/add-post/$type");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            navigateToType(context, "image");
          },
          child: SizedBox(
            height: width*0.28,
            width: width*0.28,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              color: currentTheme.backgroundColor,
              elevation: 16,
              child:Center(
                child: Icon(Icons.image_outlined,size:60 ,),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            navigateToType(context, "text");
          },
          child: SizedBox(
            height: width*0.28,
            width: width*0.28,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              color: currentTheme.backgroundColor,
              elevation: 16,
              child:Center(
                child: Icon(Icons.font_download_outlined,size:60 ,),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            navigateToType(context, "link");
          },
          child: SizedBox(
            height: width*0.28,
            width: width*0.28,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              color: currentTheme.backgroundColor,
              elevation: 16,
              child:Center(
                child: Icon(Icons.link_outlined,size:60 ,),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
