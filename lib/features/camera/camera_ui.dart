import 'dart:async';
import 'dart:io';
import 'package:chamber/features/imageManipulation/image_crop.dart';
import 'package:chamber/features/saved/saved_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:open_settings/open_settings.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  late StreamSubscription subscription;
  final wsUrl = Uri.parse('ws://192.168.0.1:8888');
  late WebSocketChannel channel;
  late StreamController streamController;
  late Timer timer;

  bool isDeviceConnected = false;
  bool runningStream = false;

  ScreenshotController screenshotController = ScreenshotController();

  int count = 0;

  // bool  = false;

  @override
  void dispose() {
    timer.cancel();
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pingServer();
    connectWebSocket();
    initTimer();
  }

  initTimer() {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!runningStream && !isDeviceConnected) {
        // If device is not connected
        // or device is not feeding video
        // Keep trying periodically
        connectWebSocket();
      }
      // if device already connected
      // periodically check if it has been disconnected
      if (runningStream == true) {
        if (channel.closeCode != null) {
          runningStream = false;
          isDeviceConnected = false;
          pingServer();
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 20,
          title: const Text(
            "Camera",
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Colors.black, fontSize: 20),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20)),
                    child: isDeviceConnected
                        ? runningStream
                            ? Container(
                                child: sensorData(),
                              )
                            : Container(
                                color: Colors.white,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LoadingAnimationWidget.threeArchedCircle(
                                        color: Colors.black87, size: 36),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "UV Chamber is getting connected ...",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : Center(
                            child: GestureDetector(
                            onTap: connectWebSocket,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors.yellow,
                                    BlendMode.modulate,
                                  ),
                                  child: Lottie.asset(
                                    'assets/findWifi.json',
                                    height: 130,
                                    width: 130,
                                  ),
                                ),
                                // GestureDetector(
                                //   onTap: () {
                                //     connectWebSocket();
                                //   },
                                //   child: Container(
                                //     height:
                                //         MediaQuery.sizeOf(context).height / 12,
                                //     width: MediaQuery.sizeOf(context).width / 2,
                                //     alignment: Alignment.center,
                                //     decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(10),
                                //         color: Colors.white),
                                //     child: const Text(
                                //       "Check",
                                //       style: TextStyle(
                                //           color: Colors.black,
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.w500),
                                //     ),
                                //   ),
                                // ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "You are not Connected to Wifi\nplease ensure you are connected",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: isDeviceConnected
                              ? const Icon(
                                  Icons.wifi_sharp,
                                  size: 30,
                                )
                              : GestureDetector(
                                  onTap: () {
                                    OpenSettings.openWIFISetting();
                                  },
                                  child: const Icon(
                                    Icons.wifi_off,
                                    size: 30,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            isDeviceConnected && runningStream
                ? Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                          50,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width / 4,
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const CircleBorder(),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const SavedImages(),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.image,
                                  size: 30,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const CircleBorder()),
                          onPressed: () async {
                            if (isDeviceConnected && runningStream) {
                              NativeShutterSound.play();
                              final directory =
                                  (await getApplicationDocumentsDirectory())
                                      .path; //from path_provide package

                              String fileName =
                                  "compuRFImage_${DateTime.now().microsecondsSinceEpoch.toString()}";
                              // TODO:
                              String path = directory;
                              print(directory);

                              final capPath =
                                  await screenshotController.captureAndSave(
                                      "/data/data/com.example.chamber/original" //set path where screenshot will be savedm,
                                      ,
                                      fileName: fileName);

                              final file = File(capPath!);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(capPath),
                                ),
                              );

                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ImageProcessing(
                                    imageFile: XFile(
                                      file.path,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera,
                              size: 50,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width / 4,
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.image,
                                size: 30,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ));
  }

  StreamBuilder<dynamic> sensorData() {
    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // var screenWidth = MediaQuery.of(context).size.width;
          // var screenHeight = MediaQuery.of(context).size.height;
          return Center(
            child: Screenshot(
              controller: screenshotController,
              child: RotatedBox(
                quarterTurns: -45,
                child: Image.memory(
                  snapshot.data,
                  gaplessPlayback: true,
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  // void checkWifiInfo() async {
  // Get Connected wifi name
  // String? wifi = await WiFiForIoTPlugin.getWiFiAPSSID() ?? "";
  // print(wifi);
  // if connected wifi name matches with PHARMA;
  // continue to connect to the websocket
  // if (wifi == "\"PHARMA\"") {
  //   setState(() {
  //     isDeviceConnected = true;
  //   });
  // connectWebSocket();
  // }
  // }

  void pingServer() async {
    channel = IOWebSocketChannel.connect(
      wsUrl,
      connectTimeout: const Duration(
        seconds: 2,
      ),
      // Replace this with your WebSocket URL
    );
    try {
      await channel.ready;
    } catch (e) {
      var snackBar = SnackBar(
        content: const Text('No device found, Capture using Mobile?'),
        action: SnackBarAction(
          label: "Yes",
          onPressed: () async {
            final ImagePicker _picker = ImagePicker();
            final XFile? photo = await _picker
                .pickImage(
              source: ImageSource.camera,
            )
                .catchError((onError) {
              if (onError.toString().contains("camera_access_denied")) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Allow Camera Usage!",
                    ),
                    action: SnackBarAction(
                        label: "Settings",
                        onPressed: () {
                          OpenSettings.openAppSetting();
                        }),
                  ),
                );
              }
              return null;
            });
            if (photo?.path == null || !mounted) return;
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ImageProcessing(
                  imageFile: XFile(
                    photo!.path,
                  ),
                ),
              ),
            );
          },
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void connectWebSocket() async {
    channel = IOWebSocketChannel.connect(
      wsUrl,
    );
    // print("we are here");
    await channel.ready;
    streamController = StreamController.broadcast();
    streamController.addStream(channel.stream);
    streamController.stream.listen((message) async {
      if (mounted) {
        setState(() {
          runningStream = true;
          isDeviceConnected = true;
        });
        // setState(() {
        //   if (message == 'connected') {
        //     runningStream = true;
        //     isDeviceConnected = true;
        //   } else {
        //     runningStream = false;
        //     isDeviceConnected = false;
        //   }
        // });
      }

      // print(state);
    });

    // print(state);
  }
}
