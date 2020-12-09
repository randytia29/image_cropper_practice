import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File _pickedImage;
  StreamSubscription<ConnectivityResult> subscription;
  @override
  void initState() {
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        Future.delayed(Duration(milliseconds: 100)).then((value) {
          showModalBottomSheet(
              context: context,
              builder: (builder) {
                return Container(
                  color: Colors.red,
                );
              });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() async {
    await subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          Center(
            child: CircleAvatar(
              radius: 80,
              child: _pickedImage == null ? Text('Picture') : null,
              backgroundImage:
                  _pickedImage != null ? FileImage(_pickedImage) : null,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            onPressed: () {
              _showPickOptionsDialog();
            },
            child: Text('Pick Image'),
          ),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            onPressed: () async {
              await AppSettings.openWIFISettings();
            },
            child: Text('Open Location Settings'),
          )
        ],
      ),
    );
  }

  _loadPicker(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile = await imagePicker.getImage(source: source);
    File picked = File(pickedFile.path);

    if (picked != null) {
      _cropImage(picked);
    }
    Navigator.pop(context);
  }

  _cropImage(File picked) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: picked.path,
        // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio4x3
        ],
        androidUiSettings: AndroidUiSettings(
            statusBarColor: Colors.red,
            toolbarColor: Colors.red,
            toolbarTitle: 'Crop Image',
            toolbarWidgetColor: Colors.white),
        maxWidth: 800);
    if (cropped != null) {
      setState(() {
        _pickedImage = cropped;
      });
    }
  }

  void _showPickOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Pick from Gallery'),
              onTap: () {
                _loadPicker(ImageSource.gallery);
              },
            ),
            ListTile(
              title: Text('Take a picture'),
              onTap: () {
                _loadPicker(ImageSource.camera);
              },
            )
          ],
        ),
      ),
    );
  }
}
