import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DisplayPictureScreen extends StatefulWidget {
  final XFile image;


  DisplayPictureScreen({
    this.image,
  });

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Display',
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.file(
          File(
            widget.image.path,
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
