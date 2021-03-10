import 'dart:typed_data';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/ArslanNasr/AndroidStudioProjects/flutter_mlkitposedetection_api/lib/camera_stream/display_picture_image_stream.dart';
import 'file:///C:/Users/ArslanNasr/AndroidStudioProjects/flutter_mlkitposedetection_api/lib/camera_snapshot/display_picture_screen.dart';

class CameraPreviewSnapshot extends StatefulWidget {
  @override
  _CameraPreviewSnapshotState createState() => _CameraPreviewSnapshotState();
}

class _CameraPreviewSnapshotState extends State<CameraPreviewSnapshot>
    with WidgetsBindingObserver {
  CameraController _controller;
  Future<void> _initController;
  var isCameraReady = false;
  XFile imageFile;

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      _initController = _controller != null ? _controller.initialize() : null;
    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller?.stopImageStream();
    super.dispose();
  }

  Widget cameraWidget(context) {
    var camera = _controller.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(_controller)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                cameraWidget(context),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Color(0xAA333639),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FlatButton.icon(
                          onPressed: () => captureImage(context),
                          icon: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Snapshot',
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }

  Future<void> initCamera() async {
    final camera = await availableCameras();
    final firstCamera = camera.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);

    _initController = _controller.initialize();

    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
  }
  captureImage(BuildContext context) {
    _controller.takePicture().then((file) {
      setState(() {
        imageFile = file;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(image: imageFile),
          ),
        );
      }
    });
  }

  void closeCameraAndStream() async {
    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
    }
    _controller?.dispose();
  }
}
