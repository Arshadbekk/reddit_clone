import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/main.dart';

import '../../../core/common/loader.dart';

class CreateCommuntiyScreen extends ConsumerStatefulWidget {
  const CreateCommuntiyScreen({super.key});

  @override
  ConsumerState createState() => _CreateCommuntiyScreenState();
}

class _CreateCommuntiyScreenState extends ConsumerState<CreateCommuntiyScreen> {
  final communityNameController=TextEditingController();
  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }
  void createcommunity(){
    ref.read(communityControllerProvider.notifier).createCommunity(communityNameController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading=ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a community'),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back_ios_new)),
      ),
      body: isLoading?loader():Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Text("Community name")),
            SizedBox(
              height: height*0.0136,
            ),
            TextField(
              controller: communityNameController,
              decoration: InputDecoration(
                hintText: "r/Community_name",
                filled: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18)
              ),
              maxLength: 21,
            ),
            SizedBox(
              height: height*0.0136,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width*0.056)
                  )
              ),
                onPressed: createcommunity,
                child: Text("Create community",style: TextStyle(
                  fontSize:width*0.0476
                ),)),


          ],
        ),
      ),
    );
  }
}
