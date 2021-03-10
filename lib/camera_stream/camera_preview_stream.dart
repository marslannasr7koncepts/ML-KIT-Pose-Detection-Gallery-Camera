import 'dart:typed_data';
import 'package:flutter_mlkitposedetection_api/camera_stream/display_picture_image_stream.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewStream extends StatefulWidget {
  @override
  _CameraPreviewStreamState createState() => _CameraPreviewStreamState();
}

class _CameraPreviewStreamState extends State<CameraPreviewStream> with WidgetsBindingObserver {

  CameraController _controller;
  Future<void> _initController;
  var isCameraReady = false;

  bool _isDetecting = false;
  CameraImage _savedImage;
  Uint8List _snapShot;
  bool _showSnapshot = false;

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;
    // Detecting a dog will be done here.
    setState(() {
      _savedImage = image;
    });
    _isDetecting = false;
  }

  Future<void> initCamera() async {
    final camera = await availableCameras();
    final firstCamera = camera.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);

    _initController = _controller.initialize().then((_) async{
      await _controller
            .startImageStream((CameraImage image) => _processCameraImage(image));
    });

    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller?.stopImageStream();
    super.dispose();
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

  static imglib.Image _convertCameraImage(CameraImage image) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    // Rotate 90 degrees to upright
    var img1 = imglib.copyRotate(img, 90);
    return img1;
  }

  @override
  Widget build(BuildContext context) {
    double mediaHeight = MediaQuery.of(context).size.height;
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
                          onPressed: () {

                            imglib.Image convertedImage =
                            _convertCameraImage(_savedImage);
                            imglib.Image fullImage = imglib.copyResize(
                                convertedImage,
                                height: mediaHeight.round());
                            _snapShot = imglib.encodePng(fullImage);
                            print('Snapshot is:${_snapShot}');
                            setState(() {
                              _showSnapshot = true;
                            });
                            Future.delayed(const Duration(seconds: 4), () {
                              setState(() {
                                _showSnapshot = false;
                              });
                            });

                            if (_snapShot != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DisplayPictureImageStream(
                                        cameraImage: _snapShot,
                                      ),
                                ),
                              ).then((value) {
                                initCamera();
                              });
                            }

                          },
                          icon: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Stream',
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
}
