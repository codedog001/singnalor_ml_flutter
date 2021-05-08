import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;
  File _image;
  List _outputs;
  var label;
  final picker = ImagePicker();

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  _clickImg() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      classifyImage(_image);
      Navigator.of(context).pop();
    }
  }

  pickImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      _outputs = output;
      label = _outputs[0]["label"];
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Language Translator'),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image == null
                        ? Container(
                            child: SizedBox(
                              height: 30,
                            ),
                          )
                        : Container(
                            child: Column(
                            children: [
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      10,
                                      MediaQuery.of(context).size.height * 0.1,
                                      10,
                                      0),
                                  child: Image.file(_image)),
                            ],
                          )),
                    SizedBox(
                      height: 20,
                    ),
                    _outputs != null
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Result: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    label.toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      background: Paint()..color = Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 20),
                                    child: RaisedButton.icon(
                                      color: Colors.blue[200],
                                      icon: Icon(Icons.image),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            // enableDrag: true,
                                            // elevation: 20,

                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.image),
                                                        iconSize: 33,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        onPressed: pickImage,
                                                      ),
                                                      IconButton(
                                                        icon:
                                                            Icon(Icons.camera),
                                                        iconSize: 33,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        onPressed: _clickImg,
                                                      ),
                                                    ])));
                                      },
                                      label: Text('pick image'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.73,
                                alignment: Alignment.center,
                                child: Text(
                                  'Please Load Image or click an image',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 20),
                                    child: RaisedButton.icon(
                                      color: Colors.blue[200],
                                      icon: Icon(Icons.image),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            // enableDrag: true,
                                            // elevation: 20,

                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.image),
                                                        iconSize: 33,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        onPressed: pickImage,
                                                      ),
                                                      IconButton(
                                                        icon:
                                                            Icon(Icons.camera),
                                                        iconSize: 33,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        onPressed: _clickImg,
                                                      ),
                                                    ])));
                                      },
                                      label: Text('pick image'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
