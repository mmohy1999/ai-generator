import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen>
    with TickerProviderStateMixin {

  final TextEditingController textController = TextEditingController(
      text:
      "A Cosmic Exploration of the Universe, With a Cannabis Plants Everywhere, View of Planets, Nebula, Moons, and Cosmic Phenomena, Rendered in 8K Resolution, V Ray");
  bool showSpinner = false;
  late final AnimationController animationController;
  bool isSent = false;
  Uint8List? imageData;


  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void generateImage() async {
    String engineId = "stable-diffusion-v1-6";
    String apiHost = 'https://api.stability.ai';
    String apiKey = 'YOUR_API_KEY';
    debugPrint(textController.text);
    final response = await http.post(
        Uri.parse('$apiHost/v1/generation/$engineId/text-to-image'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "image/png",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode({
          "text_prompts": [
            {
              "text": textController.text,
              "weight": 1,
            }
          ],
          "cfg_scale": 7,
          "height": 1024,
          "width": 1024,
          "samples": 1,
          "steps": 30,
        })
    );
    if (response.statusCode == 200) {
      try {
        debugPrint(response.statusCode.toString());
        imageData = response.bodyBytes;
      } on Exception {
        debugPrint("failed to generate image");
      }
    } else {
      debugPrint("failed to generate image");
    }
    setState(() {
      showSpinner = false;
      isSent = true;
    });
  }

  Future<void> saveUint8ListToDownloads() async {
    try {
      await requestStoragePermission();

      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
      String downloadsPath = downloadsDirectory.path;

      String newPath = '$downloadsPath/${DateTime.now().microsecond.toString()}.png';

      File file = File(newPath);
      await file.writeAsBytes(imageData!);

      print('File saved to: $newPath');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Image Generator',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0.6),
          ),
        ),
        elevation: 2,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
        child: ElevatedButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (textController.text == "") {
              return;
            }
            setState(() {
              showSpinner = true;
            });
            generateImage();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.grey,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.grey.shade300;
                }
                return null;
              },
            ),
          ),
          child: const Text(
            'Generate',
            style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.w900, color: Colors.black),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Visibility(
                      visible: showSpinner,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: 396.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SpinKitCircle(
                          color: Colors.white,
                          size: 50.0,
                          controller: animationController,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: showSpinner == false,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: 396.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: isSent
                              ? Image.memory(imageData!)
                              : Image.asset(
                            'assets/images/default_image.jpg',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        button(
                          text: 'Copy',
                          icon: Icons.copy,
                          onPressed: () {
                            if (textController.text == "") {
                              return;
                            }
                            Clipboard.setData(
                                ClipboardData(text: textController.text))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.transparent,
                                  content: Center(
                                    child: Text('Copied to Clipboard!'),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        button(
                          text: 'Download',
                          icon: Icons.download,
                          onPressed: ()  {
                            saveUint8ListToDownloads();
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    Expanded(child: bottomMessageScreen()),
                    const SizedBox(
                      height: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget bottomMessageScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(bottom: 5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff424242),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(30),
            bottomRight: const Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              color: Colors.white,
            ),
            controller: textController,
            onSubmitted: (value) {
              if (value == "") {
                return;
              }
              isSent = true;
              generateImage();
            },
            decoration: const InputDecoration(
              hintText: "Type a prompt ...",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
  button({required String text,required IconData icon,required VoidCallback onPressed}){
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade900,
            elevation: 1,
            shadowColor: Colors.grey,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.grey.shade800;
                }
                return null;
              },
            ),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8,),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );

  }

}
