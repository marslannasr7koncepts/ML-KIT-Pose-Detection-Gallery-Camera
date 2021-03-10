import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

class DisplayPictureImageStream extends StatefulWidget {
  final Uint8List cameraImage;

  DisplayPictureImageStream({
    this.cameraImage,
  });

  @override
  _DisplayPictureImageStreamState createState() =>
      _DisplayPictureImageStreamState();
}

class _DisplayPictureImageStreamState extends State<DisplayPictureImageStream> {
  List<int> png;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('ImageStreamNextWidgetIs:${widget.cameraImage}');
    // convertYUV420toImage(widget.cameraImage).then((resultPng) {
    //   setState(() {
    //     png = resultPng;
    //   });
    //   print('Image Stream Result is:' + png.toString());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stream Image',
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.memory(
          widget.cameraImage,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Future<List<int>> convertImagetoPng(CameraImage image) async {
    try {
      imglib.Image img;
      if (image.format.group == ImageFormatGroup.yuv420) {
        img = _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        img = _convertBGRA8888(image);
      }

      imglib.PngEncoder pngEncoder = new imglib.PngEncoder();

      // Convert to png
      List<int> png = pngEncoder.encodeImage(img);
      return png;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

  // CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
  imglib.Image _convertYUV420(CameraImage image) {
    var img = imglib.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img.data[planeOffset + x] = newVal;
      }
    }

    return img;
  }

  // CameraImage BGRA8888 -> PNG
// Color
  imglib.Image _convertBGRA8888(CameraImage image) {
    return imglib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imglib.Format.bgra,
    );
  }

  Future<List<int>> convertYUV420toImage(
      CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;

      // imglib -> Image package from https://pub.dartlang.org/packages/image
      var img = imglib.Image(width, height); // Create Image buffer

      Plane plane = image.planes[0];
      const int shift = (0xFF << 24);

      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < width; x++) {
        for (int planeOffset = 0; planeOffset < height * width; planeOffset += width) {
          final pixelColor = plane.bytes[planeOffset + x];
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          // Calculate pixel color
          var newVal =
          shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
          img.data[planeOffset + x] = newVal;
        }
      }

      imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
      // Convert to png
      List<int> png = pngEncoder.encodeImage(img);
      return png;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

}
