import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';

import '../../../core/utils.dart';
import '../../../main.dart';
import '../../../models/community_model.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  File? bannerFile;
  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  List<Community> communities = [];
  Community? selectedCommunity;
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void sharePost() {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0],
          file: bannerFile);
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0],
          description: descriptionController.text.trim());
    } else if (widget.type == 'link' && titleController.text.isNotEmpty && linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity!,
          link: linkController.text.trim());
    }else{
      showSnackBar(context, "Please enter all fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isTypeImage = widget.type == "image";
    final isTypeText = widget.type == "text";
    final isTypeLink = widget.type == "link";
    final isLoading = ref.watch(postControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Post ${widget.type}"),
        actions: [TextButton(onPressed: () {
          sharePost();
        }, child: Text("Share"))],
      ),
      body: isLoading?loader():Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: "Enter title here",
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                maxLength: 30,
              ),
              SizedBox(
                height: 10,
              ),
              if (isTypeImage)
                GestureDetector(
                  onTap: () {
                    selectBannerImage();
                  },
                  child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      dashPattern: [10, 4],
                      strokeCap: StrokeCap.round,
                      color: currentTheme.textTheme.bodyText2!.color!,
                      child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.05)),
                          child: bannerFile != null
                              ? Image.file(bannerFile!)
                              : Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                  ),
                                ))),
                ),
              if (isTypeText)
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Enter Description here",
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 5,
                ),
              if (isTypeLink)
                TextField(
                  controller: linkController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Enter Link here",
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              Align(
                  alignment: Alignment.topLeft, child: Text("Select Community")),
              SizedBox(
                height: width*0.04,
              ),
              ref.watch(userCommunitiesProvider).when(
                    data: (data) {
                      communities = data;

                      if (data.isEmpty) {
                        return SizedBox();
                      }
                      return Container(
                        height: width * 0.15,
                        width: width * 0.4,
                        decoration: BoxDecoration(
                            color: currentTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(width * 0.03),
                            border: Border.all(
                                color: currentTheme.primaryColorLight)),
                        child: DropdownButton(
                          underline: Text(""),
                          borderRadius: BorderRadius.circular(width * 0.02),
                          hint: Text("Commuities"),
                          autofocus: true,
                          focusColor: currentTheme.backgroundColor,
                          dropdownColor: currentTheme.backgroundColor,
                          value: selectedCommunity ?? data[0],
                          items: data
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e.name)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCommunity = val;
                            });
                          },
                        ),
                      );
                    },
                    error: (error, stackTrace) =>
                        ErrorText(error: error.toString()),
                    loading: () => loader(),
                  )
            ],
          ),
        ),
      ),
    );
  }
}
