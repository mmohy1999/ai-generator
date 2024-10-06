import 'package:ai_integration/chat/chat_bot.dart';
import 'package:ai_integration/code/code_generator.dart';
import 'package:ai_integration/image_integration/image_integration.dart';
import 'package:ai_integration/remove_bg/remove_bg.dart';
import 'package:ai_integration/translate/translate.dart';
import 'package:flutter/material.dart';

class GridDashboard extends StatelessWidget {

  const GridDashboard({super.key});

  @override
  Widget build(BuildContext context) {
   final myList = [
     //ChatBot
     Items(
         title: "ChatBot",
         subtitle: "Engage in Real-Time Conversations with Intelligent AI for Instant Answers and Seamless Interaction.\nby Api gemini-1.5-flash",
         img: "assets/images/chatbot.png",
         screen:const ChatScreen()),
     //Code Generator
     Items(
         title: "Code Generator",
         subtitle: "Effortlessly Generate Optimized Code Snippets for Your Projects with AI-Powered Precision.\nby Api textcortex",
         img: "assets/images/coding.png",
         screen:const CodeGeneratorScreen()),
     //Image Generator
     Items(
         title: "Image Generator",
         subtitle: "Create Stunning Visuals Instantly with the Power of AI-Driven Imagination.\nby Api stability.ai",
         img: "assets/images/image_editor.png",
         screen:const ImageGeneratorScreen()),
     //remove bg
     Items(
         title: "Remove BG",
         subtitle: "Effortlessly Remove Backgrounds from Any Image with Precision and Speed.\nby Api remove.bg",
         img: "assets/images/image_editor.png",
         screen:const RemoveBg()),
     //Translator
     Items(
         title: "Translator",
         subtitle: "Instantly Translate Between Any Languages with Seamless Accuracy and Ease.\nby Api textcortex",
         img: "assets/images/translation.png",
         screen:const TranslatorScreen()),

   ];
    return Flexible(
      child: GridView.count(
        childAspectRatio: 1.0,
        padding: const EdgeInsets.only(left: 16, right: 16),
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        children: myList.map((data) {
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => data.screen),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff453658),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(data.img, width: 42),
                  const SizedBox(height: 2),
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String img;
  Widget screen;
  Items({required this.title,required this.subtitle,required this.img, required this.screen});
}