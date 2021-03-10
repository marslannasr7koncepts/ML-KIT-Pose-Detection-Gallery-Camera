import 'package:flutter/material.dart';
import 'file:///C:/Users/ArslanNasr/AndroidStudioProjects/flutter_mlkitposedetection_api/lib/camera_snapshot/camera_preview_snapshot.dart';
import 'file:///C:/Users/ArslanNasr/AndroidStudioProjects/flutter_mlkitposedetection_api/lib/gallery_image_detector/pose_detector_view.dart';
import 'package:flutter_mlkitposedetection_api/camera_stream/camera_preview_stream.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Detection',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pose Detection Example App'),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Card(
            elevation: 5,
            margin: EdgeInsets.only(bottom: 10,left: 10,right: 10),
            child: ListTile(
              title: Text('Pose Detector From Gallery'),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => PoseDetectorView()));
              },
            ),
          ),

          Card(
            elevation: 5,
            margin: EdgeInsets.only(bottom: 10,left: 10,right: 10),
            child: ListTile(
              title: Text('Camera View with Snapshot'),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => CameraPreviewSnapshot()));
              },
            ),
          ),

          Card(
            elevation: 5,
            margin: EdgeInsets.only(bottom: 10,left: 10,right: 10),
            child: ListTile(
              title: Text('Camera View with Stream'),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => CameraPreviewStream()));
              },
            ),
          ),

        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;

  const CustomCard(this._label, this._viewPage);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(_label),
        onTap: () {
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => _viewPage));

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CameraPreviewSnapshot()));
        },
      ),
    );
  }
}


