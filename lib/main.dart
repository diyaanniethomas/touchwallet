import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:touchwallet/ui/constants.dart';

import 'ui/camera.dart';
import 'ui/gallery.dart';

Future<void> main() async {
  runApp(const BottomNavigationBarApp());
}

class BottomNavigationBarApp extends StatelessWidget {
  const BottomNavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: HomeScreen(),
        theme: ThemeData.dark().copyWith(
          primaryColor: defaultPropertyBackgroundColour,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  late CameraDescription cameraDescription;

  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
  }

  void launchCam() async {
    if (cameraIsAvailable) {

      List<CameraDescription> cameras = await availableCameras();
      if (cameras.isNotEmpty) {
    
        CameraDescription cameraDescription = cameras.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(body: CameraScreen(camera: cameraDescription)),
          ),
        );
      } else {
        debugPrint("No available cameras found.");
      }
    } else {
      debugPrint("Camera is not available on this platform.");
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('TouchWallet'),
      backgroundColor: Colors.black.withOpacity(0.5),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icon.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                launchCam();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Start Live Camera',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'TouchWallet is an app designed for visually impaired individuals. It helps to identify currency by speaking out the detected currency in real-time through the device camera.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
    }