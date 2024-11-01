import 'dart:io';
import 'package:chamber/features/saved/saved_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';

Future main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
  ));
  WidgetsFlutterBinding.ensureInitialized();

  final path = Directory("/data/data/com.example.chamber/images");
  if ((await path.exists())) {
  } else {
    await path.create();
  }

  final path2 = Directory("/data/data/com.example.chamber/original");
  if ((await path2.exists())) {
  } else {
    await path2.create();
  }

  // var status = await Permission.location.isGranted;
  // if (status) {
  // We haven't asked for permission yet or the permission has been denied before, but not permanently.
  // }

// You can also directly ask permission about its status.
  // else {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.location,
  //   ].request();
  // The OS restricts access, for example, because of parental controls.
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compu-Rf',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SavedImages(),
    );
  }
}
