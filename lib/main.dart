// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class ImageBloc {
  // InputStream(Image)
  final ReplaySubject<File> _inputFile = ReplaySubject<File>();
  Sink<File> get inputFile => _inputFile;

  // OutputStream(Pickup)
  Stream<Uint8List> _resultUint8List = new Stream.empty();
  Stream<Uint8List> get resultUint8List => _resultUint8List;

  ImageBloc() {
    _resultUint8List = _inputFile
        .asyncMap((File file) => file.readAsBytes())
        .map((List<int> bytes) => base64.encode(bytes))
        .map((String base64String) => base64.decode(base64String))
        .asBroadcastStream();
  }
}

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Image Picker Demo',
      home: new MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ImageBloc _imageBloc = new ImageBloc();
  //VoidCallback listener;

  void _onImageButtonPressed(ImageSource source) async {
    _imageBloc.inputFile.add(await ImagePicker.pickImage(source: source));
  }

  Widget _previewImage() {
    return StreamBuilder<Uint8List>(
        stream: _imageBloc.resultUint8List,
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          if (snapshot.hasData) {
            return new Image.memory(snapshot.data);
          }
          return new Text('not Image');
        });

//    return FutureBuilder<File>(
//        future: _futureFile,
//        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
//          if (snapshot.connectionState == ConnectionState.done &&
//              snapshot.data != null) {
////            return Image.file(snapshot.data);
////            File imageFile = new File(snapshot.data.path);
////            List<int> imageBytes = imageFile.readAsBytesSync();
//            // バイトのリストとして読み込み
//            List<int> imageBytes = snapshot.data.readAsBytesSync();
//            // base64にエンコード
//            String base64Image = base64.encode(imageBytes);
//            // (出してみる)
//            print(base64Image);
//            // base64からデコード
//            Uint8List bytes = base64.decode(base64Image);
//            // 画像として表示
//            return new Image.memory(bytes);
//          } else if (snapshot.error != null) {
//            return const Text(
//              'Error picking image.',
//              textAlign: TextAlign.center,
//            );
//          } else {
//            return const Text(
//              'You have not yet picked an image.',
//              textAlign: TextAlign.center,
//            );
//          }
//        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _previewImage(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery);
            },
            heroTag: 'image0',
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo_library),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}
