import 'dart:io';
import 'package:chamber/features/camera/camera_ui.dart';
import 'package:chamber/features/see_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../imageManipulation/image_crop.dart';

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
    String newPath = '${imageFile.parent.path}/$newName';
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
                  // Navigator.pushReplacement(
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const CameraPage(),
                    ),
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10))),
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Icon(
                      Icons.camera_alt,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 0.5,
                height: 1,
              ),
              GestureDetector(
                onTap: () async {
                  XFile? file = await _pickImage();
                  if (file != null) {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ImageProcessing(
                          imageFile: file,
                        ),
                      ),
                    ).then(
                      (_) => setState(
                        () {
                          _loadImages();
                        },
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text(
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
                    padding: const EdgeInsets.all(4),
                    itemBuilder: (context, index) {
                      File imageFile = _imageFiles[index];

                      return Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
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
                                                  const Duration(
                                                      milliseconds: 400),
                                              reverseTransitionDuration:
                                                  const Duration(
                                                      milliseconds: 400),
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
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.share),
                                              color: Colors.black87,
                                              onPressed: () async {
                                                Share.shareXFiles(
                                                  [
                                                    XFile(
                                                      imageFile.path,
                                                    ),
                                                  ],
                                                  text: imageFile.path
                                                      .split('/')
                                                      .last,
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit),
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
                                                      title: const Text(
                                                          'Rename Image'),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            onChanged: (value) {
                                                              newName = value;
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  'Enter new name',
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
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
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.lightBlueAccent),
                                                                child: const Text(
                                                                    'Cancel',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
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
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.lightBlueAccent),
                                                                child:
                                                                    const Text(
                                                                  'Rename',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
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
                                              icon: const Icon(Icons.delete),
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
