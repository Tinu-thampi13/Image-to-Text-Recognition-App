// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
// ignore: library_prefixes
import 'dart:io' as Io;
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import 'package:textrecog/apikey.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// ignore: camel_case_types
class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

// ignore: camel_case_types
class _homescreenState extends State<homescreen> {
  late File pickedimage;
  bool scanning = false;
  String scannedText = '';

  optionsdialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () => pickimage(ImageSource.gallery),
                child: const Text('Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    )),
              ),
              SimpleDialogOption(
                onPressed: () => pickimage(ImageSource.camera),
                child: const Text('Camera',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    )),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    )),
              )
            ],
          );
        });
  }

  dynamic hello = const AssetImage('assets/logo/logo.png');
  pickimage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    setState(() {
      scanning = true;
      pickedimage = File(image!.path);

      hello = pickedimage == null
          ? const AssetImage('assets/logo/logo.png')
          : FileImage(pickedimage);
    });
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    Uint8List bytes = Io.File(pickedimage.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    final url = Uri.parse("https://api.ocr.space/parse/image");
    var data = {"base64Image": "data:image/jpg;base64,$img64"};
    var header = {"apikey": apikey};
    http.Response response = await http.post(url, body: data, headers: header);
    Map result = jsonDecode(response.body);
    setState(() {
      scanning = false;
      scannedText = result['ParsedResults'][0]['ParsedText'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: Null,
            onPressed: () {
              FlutterClipboard.copy(scannedText).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Successfully Copied!!'),
                ));
              });
            },
            child: const Icon(
              Icons.copy,
              size: 28,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: Null,
            onPressed: () {
              Share.share(
                scannedText,
              );
            },
            child: const Icon(
              Icons.reply,
              size: 28,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: Null,
            onPressed: () {
              setState(() {
                hello = const AssetImage('assets/logo/logo.png');
                pickedimage = File("");
                scannedText = "";
              });
              // Share.share(
              //   scannedText,
              // );
            },
            child: const Icon(
              Icons.delete,
              size: 28,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              const SizedBox(
                height: 70,
              ),
              const Text(
                'TEXT EXTRACTOR',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                padding: hello == const AssetImage('assets/logo/logo.png')
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.all(30),
                child: InkWell(
                  onTap: () => {
                    optionsdialog(context),
                  },
                  child: Image(
                    width: 550,
                    height: 250,
                    image: hello,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              scanning
                  ? const Text('Scanning....')
                  : Text(
                      scannedText,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
