import 'dart:io';
import 'dart:typed_data';

import 'package:before_after_image_slider_nullsafty/before_after_image_slider_nullsafty.dart';
import 'package:flutter/material.dart';
import 'package:image_background_remover/remove_bg_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool imagePicked = false;
  bool removedImageBackground = false;
  bool isLoading = false;
  Uint8List? image;
  String imagePath = '';
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Remover'),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
              onPressed: () {
                if (removedImageBackground) {
                  downloadImage();
                } else {
                  customSnackbar('Remove background first');
                }
              },
              icon: Icon(Icons.download)),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    imagePicked = false;
                    removedImageBackground = false;
                    isLoading = false;
                    imagePath = '';
                    image = null;
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green),
                    child: Text('New'),
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: isLoading
                              ? Text(
                                  'Removing Background...',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                              : removedImageBackground
                                  ? BeforeAfter(
                                      thumbColor: Colors.green,
                                      overlayColor: Colors.green.shade200,
                                      imageHeight: 250,
                                      imageWidth: 250,
                                      beforeImage: Image.file(
                                          fit: BoxFit.fill, File(imagePath)),
                                      afterImage: Screenshot(
                                          controller: screenshotController,
                                          child: Image.memory(
                                              fit: BoxFit.fill, image!)))
                                  : imagePicked
                                      ? InkWell(
                                          onTap: pickImage,
                                          child: Container(
                                            height: 250,
                                            width: 250,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                  fit: BoxFit.fill,
                                                  File(imagePath)),
                                            ),
                                          ))
                                      : InkWell(
                                          onTap: pickImage,
                                          child: Container(
                                              height: 250,
                                              width: 250,
                                              child: Center(
                                                  child: Text(
                                                'Select Image',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              )))),
                        ),
                      ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: () async {
                          if (!imagePicked) {
                            customSnackbar('Please select an image first');
                          } else {
                            isLoading = true;
                            setState(() {});
                            image = await RemoveBgApi.removebg(imagePath);
                            if (image != null) {
                              removedImageBackground = true;
                              isLoading = false;
                              setState(() {});
                            } else {
                              isLoading = false;
                              setState(() {});
                              customSnackbar('Failed to remove background');
                            }
                          }
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Remove Background'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //Methods
  pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) {
      imagePath = image.path;
      imagePicked = true;
      setState(() {});
    } else {
      customSnackbar('No image selected');
    }
  }

  downloadImage() async {
    var permission = await Permission.storage.request();
    var folderName = 'ImageBackgroundRemover';
    var fileName = '${DateTime.now().microsecond}.png';
    if (permission.isGranted) {
      final directory = Directory('storage/emulated/0/$folderName/');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      await screenshotController.captureAndSave(directory.path,
          delay: Duration(microseconds: 100),
          fileName: fileName,
          pixelRatio: 1.0);
      customSnackbar('Image downloaded');
    }
  }

  //Snackbar
  customSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
