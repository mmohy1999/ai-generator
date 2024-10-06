import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CodeGeneratorScreen extends StatefulWidget {
  const CodeGeneratorScreen({super.key});

  @override
  State<CodeGeneratorScreen> createState() => _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends State<CodeGeneratorScreen>
    with TickerProviderStateMixin {

  final TextEditingController textController = TextEditingController(
      text:
      "multiply two numbers without using * operator");
  bool showSpinner = false;
  late final AnimationController animationController;
  bool isSent = false;
  String generatedText='';
  String selectedLanguage = "java";

  final List<String> languages = [
    'python',
    'java',
    'javascript',
    'go',
    'php',
    'js_regex',
  ];

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

  void generateCode() async {

    Dio dio=Dio();
    const apiKey = 'YOUR_API_KEY';
    debugPrint(textController.text);
    Response response = await dio.post(
      'https://api.textcortex.com/v1/codes',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
      data: {
        "max_tokens": 2048,
        "mode": selectedLanguage,
        "model": "icortex-1",
        "n": 1,
        "temperature": null,
        "text": textController.text
      },
    );
    if (response.statusCode == 200) {
      try {
        debugPrint(response.statusCode.toString());
        generatedText = response.data['data']['outputs'][0]['text'];
      } on Exception {
        debugPrint("failed to generate code");
      }
    } else {
      debugPrint("failed to generate image");
    }
    setState(() {
      showSpinner = false;
      isSent = true;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Code Generator',
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
            generateCode();
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
                          color: const Color(0xff424242),
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
                      child:Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: 396.8,
                        decoration: BoxDecoration(
                          color: const Color(0xff424242),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: isSent
                              ? Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8.0,top: 8),
                            child: SingleChildScrollView(child: Text(generatedText)),
                          )
                              : const Padding(
                            padding: EdgeInsetsDirectional.only(start: 8.0,top: 8),
                            child: Text('data'),
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
                            if (generatedText == "") {
                              return;
                            }
                            Clipboard.setData(
                                ClipboardData(text: generatedText))
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
                        Expanded(
                          child: dropDownWidget(selectedLanguage, (newValue) {
                            setState(() {
                              selectedLanguage = newValue!;
                            });
                          }, languages[1])),
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
              generateCode();
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
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.only(bottom: 10),
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
  Widget dropDownWidget(String language, Function(String? value) onChanged,
      String defaultLanguage) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade900, borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          dropdownColor: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          value: language.isNotEmpty ? language : defaultLanguage,
          items: languages.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style:  TextStyle(
                  fontSize:selectedLanguage==items? 14: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

}
