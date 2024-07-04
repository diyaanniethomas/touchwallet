import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:touchwallet/helper/image_classification_helper.dart';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  State<StatefulWidget> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late CameraController cameraController;
  late ImageClassificationHelper imageClassificationHelper;
  Map<String, double>? classification;
  bool _isProcessing = false;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);
    flutterTts.setLanguage("en-US");
    initCamera();
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper.initHelper();
  }

  bool isSpeaking = false; // Add this variable to track speech status

  void initCamera() {
    cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      imageFormatGroup:
          Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    );
    cameraController.initialize().then((value) {
      cameraController.startImageStream(imageAnalysis);
      if (mounted) {
        setState(() {});
      }
    });
  }
Future<void> imageAnalysis(CameraImage cameraImage) async {
  if (_isProcessing) {
    return;
  }
  _isProcessing = true;
  classification =
      await imageClassificationHelper.inferenceCameraFrame(cameraImage);
  _isProcessing = false;
  if (mounted) {
    setState(() {});
  }
  // Check if the classification is not null and not empty
  if (classification != null && classification!.isNotEmpty) {
    // Get the entry with the highest probability
    var topEntry = classification!.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    // Speak the key of the top entry
    _speak(topEntry.key);
  }
}


  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    cameraController.dispose();
    imageClassificationHelper.close();
    _speechTimer.cancel(); // Cancel the speech timer
    super.dispose();
  }

// Inside CameraScreenState class
  late Timer _speechTimer;

  Future<void> _speak(String text) async {
    // If already speaking, return to prevent overlapping speeches
    if (isSpeaking) return;

    // Set speaking status to true
    isSpeaking = true;

    // Speak the text
    await flutterTts.speak(text);

    // Wait for a delay before resetting speaking status
    const delayDuration =
        Duration(milliseconds: 5000); // Adjust the delay duration as needed
    _speechTimer = Timer(delayDuration, () {
      // Reset speaking status after the delay
      isSpeaking = false;
    });
  }

  Widget cameraWidget(context) {
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * cameraController.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(cameraController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(
      SizedBox(
        child: (!cameraController.value.isInitialized)
            ? Container()
            : cameraWidget(context),
      ),
    );
    list.add(Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (classification != null)
              ...(classification!.entries.toList()
                    ..sort(
                      (a, b) => a.value.compareTo(b.value),
                    ))
                  .reversed
                  .take(3)
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        _speak(e.key);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.black,
                        child: Row(
                          children: [
                            Text(e.key),
                            const Spacer(),
                            Text(e.value.toStringAsFixed(2)),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ));

    return SafeArea(
      child: Stack(
        children: list,
      ),
    );
  }
}
