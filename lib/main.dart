
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sweettext/Translator.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleTranslator translator = GoogleTranslator();
  XFile? imageFile;

  bool  textScanning = false;
  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Text Recognization"),
      ),
      body: Center(
          child: SingleChildScrollView(
            child:Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(textScanning) const CircularProgressIndicator(),
                    if( !textScanning  && imageFile == null)
                      Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300]!,
                      ),

                    if (imageFile != null) Image.file(File (imageFile!.path)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 300,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal:5),
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)
                                ),
                              ),
                              onPressed: () {
                                getImage(ImageSource.gallery);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 30,
                                    ),
                                    Text("Gallery",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.brown[900]),
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal:5),
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)
                                ),
                              ),
                              onPressed: () {
                                getImage(ImageSource.camera);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                    ),
                                    Text("Camera",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.brown[900]),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      child: Text(scannedText,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        copyToClipboard(scannedText);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Copied to Clipboard"),
                            )
                        );
                      },
                      child: Text("Copy to Clipboard"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Call the function to clear recognized text
                        clearRecognizedText();
                      },
                      child: Text(' Clear Recognized Text '),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder:(context)=>TranslatorApp()));
                      },
                      child: Text(' Go for Translator '),
                    ),
                  ],

                )),
          )),
    );
  }

  void  getImage(ImageSource source) async {
    try{
      final pickedImage = await ImagePicker().pickImage(source: source);
      if(pickedImage != null){
        textScanning = true;
        imageFile = pickedImage;
        setState(() {

        });
        getRecognizedText(pickedImage);
      }
    }
    catch(e){
      textScanning = false;
      imageFile = null;
      scannedText = "Error";
      setState(() {

      });
    }

  }

  void getRecognizedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    for(TextBlock block in recognizedText.blocks){
      for(TextLine line in block.lines){
        scannedText += line.text + "\n" ;
      }
    }
    textScanning = false;
    setState(() {

    });
  }
  @override
  void initState(){
    super.initState();
  }

  void copyToClipboard(scannedText) {
    Clipboard.setData(ClipboardData(text: scannedText));
  }

  void clearRecognizedText() {
    setState(() {
      scannedText = '';
    });
  }
  }
