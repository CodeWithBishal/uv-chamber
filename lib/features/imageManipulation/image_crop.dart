import 'dart:ffi';
import 'dart:io';
// import 'dart:isolate';
// import 'dart:typed_data';
// import 'package:chamber/features/saved/saved_images.dart';
// import 'package:flutter/cupertino.dart';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path2;
import 'package:image_cropper/image_cropper.dart';
// import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ffi/ffi.dart';
// import 'package:simple_edge_detection/edge_detection.dart';
// import 'package:simple_edge_detection/edge_detection.dart';

class ImageProcessing extends StatefulWidget {
  const ImageProcessing({super.key, required this.imageFile});
  final XFile imageFile;
  @override
  State<ImageProcessing> createState() => _ImageProcessingState();
}

class _ImageProcessingState extends State<ImageProcessing> {
  // late CroppedFile croppedFileOutput;
  Directory directory = Directory("/data/data/com.example.chamber/images");
  final dylib = Platform.isAndroid
      ? DynamicLibrary.open("libOpenCV_ffi.so")
      : DynamicLibrary.process();
  File? _processedImage;

  @override
  void initState() {
    callCropper();
    super.initState();
  }

  Future<void> callCropper() async {
    // EdgeDetectionResult result = await EdgeDetector().detectEdges(
    //   widget.imageFile.path,
    // );
    // EdgeDetection.processImage(widget.imageFile.path, result, 0)
    //     .then((value) => print(value));
    var imagePath = widget.imageFile.path;
    var extension = path2.extension(imagePath);
    if (!extension.toString().toLowerCase().contains("jpg")) {
      imagePath = await handleNonJPGImage(imagePath);
    }
    var savePath =
        "${path2.withoutExtension(imagePath)}_crop${path2.extension(imagePath)}";
    bool cropped = await EdgeDetection.detectEdgeFromGallery(
      File(imagePath).uri.toString(),
      savePath,
      androidCropTitle: 'Crop', // use custom localizations for android
      androidCropBlackWhiteTitle: 'Black White',
      androidCropReset: 'Reset',
    );
    final autoCroppedFile = File(savePath);
    if (!mounted) return;
    if (!cropped || !autoCroppedFile.existsSync() && mounted) {
      Navigator.pop(context);
    } else {
      calculateTLC(CroppedFile(savePath));
    }

    // CroppedFile? croppedFile = await ImageCropper().cropImage(
    //   sourcePath: widget.imageFile.path,
    //   aspectRatioPresets: [
    //     CropAspectRatioPreset.square,
    //     CropAspectRatioPreset.ratio3x2,
    //     CropAspectRatioPreset.original,
    //     CropAspectRatioPreset.ratio4x3,
    //     CropAspectRatioPreset.ratio16x9
    //   ],
    //   uiSettings: [
    //     AndroidUiSettings(
    //         toolbarTitle: 'Cropper',
    //         toolbarColor: Colors.white,
    //         toolbarWidgetColor: Colors.black,
    //         initAspectRatio: CropAspectRatioPreset.original,
    //         lockAspectRatio: false),
    //     IOSUiSettings(
    //       title: 'Cropper',
    //     ),
    //     WebUiSettings(
    //       context: context,
    //     ),
    //   ],
    // );

    // if (croppedFile?.path != null) {
    //   print(croppedFile!.path);
    //   print("path ha bhai");
    // calculateTLC(CroppedFile(widget.imageFile.path));
    //   // await processImage(croppedFile);
    //   // await FileSaver.instance.saveFile(file: croppedFile.,);
    // } else {
    //   if (!mounted) return;
    //   Navigator.pop(context);
    // }

    // Rename (move) the cropped file to the destination directory
  }

  Future<String> handleNonJPGImage(String imgPath) async {
    final image = img.decodeImage(File(imgPath).readAsBytesSync());
    File(path2.setExtension(imgPath, ".jpg"))
        .writeAsBytesSync(img.encodeJpg(image!));

    return path2.setExtension(imgPath, ".jpg");
  }

  void calculateTLC(CroppedFile croppedFile) {
    //ffi
    final imagePath = croppedFile.path.toNativeUtf8();
    final imageFfi = dylib.lookupFunction<Bool Function(Pointer<Utf8>),
        bool Function(Pointer<Utf8>)>('detect_contour_tlc');
    if (imageFfi(imagePath)) {
      setState(() {
        _processedImage = File(imagePath.toDartString());
      });
      saveImage(imagePath.toDartString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please crop the image properly and leave no margins! Redirecting...",
          ),
          action: SnackBarAction(
            label: "Crop",
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ImageProcessing(
                    imageFile: XFile(croppedFile.path),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

//ffi
  }

  void saveImage(String finalImage) async {
    String originalFilenameWithoutExtension =
        widget.imageFile.path.split('/').last.split('.').first;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String uniqueFilename = '${originalFilenameWithoutExtension}_$timestamp';

// Specify the path with the unique filename
    String filePath = '/data/data/com.example.chamber/images/$uniqueFilename';

// Write the image data to the file
    await File(filePath).writeAsBytes(File(finalImage).readAsBytesSync());
  }
// REMOVED: AS WE ARE CALCULATING TLC LOCALLY
//   Future<void> processImage(CroppedFile _selectedImage) async {
//     // Get the original filename without the path and extension
//     String originalFilenameWithoutExtension =
//         widget.imageFile.path.split('/').last.split('.').first;

// // Rename the file to have a .jpeg extension
// //     String renamedFilename = '$originalFilenameWithoutExtension.jpeg';
// //     File img = File(widget.imageFile.path);
// //
// //     final image = i.decodeImage(img.readAsBytesSync())!;
// //     print(originalFilenameWithoutExtension);
// //     File(img.path + ".jpeg").writeAsBytesSync(i.encodeJpg(image));

// // Save the renamed file
// //     final v = await widget.imageFile
// //         .rename('path/to/your/save/location/$renamedFilename');
// //     print(v);

//     var request = http.MultipartRequest(
//         'POST', Uri.parse('https://chamber.pythonanywhere.com/upload'));
//     request.files
//         .add(await http.MultipartFile.fromPath('file', _selectedImage.path));

//     http.StreamedResponse response = await request.send();
//     print(response.stream);

//     // Check if the request was successful
//     if (response.statusCode == 200) {
//       ByteStream byteStream = response.stream;

//       // Convert the byte stream to a Uint8List
//       Uint8List byteList = await byteStream.toBytes();

//       // Save the Uint8List as a file
//       String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

// // Create a unique filename by combining the original filename and timestamp
//       String uniqueFilename = '${originalFilenameWithoutExtension}_$timestamp';

// // Specify the path with the unique filename
//       String filePath = '/data/data/com.example.chamber/images/$uniqueFilename';

// // Write the image data to the file
//       await File(filePath).writeAsBytes(byteList);
//       // Update the UI
//       _processedImage = File(filePath);
//       print("Done");
//       setState(() {});
//     } else {
//       // Handle error
//       print('Error: ${response.reasonPhrase}');
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _processedImage == null
            ? const Text('Processing')
            : Text(
                path2.basename(
                  _processedImage?.path.replaceAll("image_cropper_", "") ?? "",
                ),
              ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: _processedImage != null
            ? SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: Image.file(
                  _processedImage!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.black87, size: 36),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Processing Image...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
