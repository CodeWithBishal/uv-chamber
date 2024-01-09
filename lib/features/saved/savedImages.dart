import 'dart:io';

import 'package:chamber/features/camera/cameraUi.dart';
import 'package:chamber/features/seeImage.dart';
import 'package:chamber/model/savedElementModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_share/social_share.dart';

import '../imageManipulation/imageCrop.dart';

class SavedImages extends StatefulWidget {
  const SavedImages({super.key});

  @override
  State<SavedImages> createState() => _SavedImagesState();
}

class _SavedImagesState extends State<SavedImages> {
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() async {
    Directory directory = Directory("/data/data/com.example.chamber/images");

    List<FileSystemEntity> files = directory.listSync();

    setState(() {
      _imageFiles = files.whereType<File>().toList();
    });
  }

  Future<void> _deleteImage(File imageFile) async {
    await imageFile.delete();
    _loadImages();
  }

  Future<void> _renameImage(File imageFile, String newName) async {
    String newPath = imageFile.parent.path + '/' + newName;
    await imageFile.rename(newPath);
    _loadImages();
  }

  Future<XFile?> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade, child: CameraPage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(
                      Icons.camera_alt,
                    ),
                  ),
                ),
              ),
              Container(
                width: 0.5,
                height: 1,
              ),
              GestureDetector(
                onTap: () async {
                  XFile? file = await _pickImage();
                  if (file != null) {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: ImageProcessing(
                              imageFile: file,
                            ))).then((_) => setState(() {
                          _loadImages();
                        }));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(
                      Icons.upload,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Recents",
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Colors.black, fontSize: 20),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _imageFiles.length,
                    padding: EdgeInsets.all(4),
                    itemBuilder: (context, index) {
                      File imageFile = _imageFiles[index];

                      return Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black38, blurRadius: 0.5)
                                ]),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Hero(
                                    tag: index,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 400),
                                              reverseTransitionDuration:
                                                  Duration(milliseconds: 400),
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  SeeImage(
                                                imageFile: imageFile,
                                                tag: index,
                                              ),
                                            ));
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1.2 /
                                                4,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.black87,
                                            image: DecorationImage(
                                                image: FileImage(imageFile))),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  // Wrap the Column with Expanded
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          imageFile.path.split('/').last,
                                        ),
                                        Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.share),
                                              color: Colors.black87,
                                              onPressed: () async {
                                                // final result =
                                                //     await Share.shareXFiles([
                                                //   XFile(imageFile.path)
                                                // ],
                                                //         text: imageFile.path
                                                //             .split('/')
                                                //             .last);
                                                try {
                                                  SocialShare.shareOptions(
                                                      imageFile.path
                                                          .split('/')
                                                          .last,
                                                      imagePath:
                                                          imageFile.path);
                                                } catch (e) {}
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              color: Colors.black87,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    String newName = '';

                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      title:
                                                          Text('Rename Image'),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            onChanged: (value) {
                                                              newName = value;
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Enter new name',
                                                            ),
                                                          ),
                                                          SizedBox(height: 16),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                    'Cancel',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.lightBlueAccent),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  // Rename the image
                                                                  _renameImage(
                                                                      imageFile,
                                                                      newName);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  'Rename',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.lightBlueAccent),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              color: Colors.red,
                                              onPressed: () {
                                                _deleteImage(imageFile);
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            )));
  }
}
