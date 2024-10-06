import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<ChatMessage> messages = [];

  final ChatUser user = ChatUser(id: 'user', firstName: "You");
  final ChatUser bot = ChatUser(id: 'bot', firstName: "Bot");



  Future<void> sendMessage(ChatMessage message) async {
    const String apiKey = "YOUR_API_KEY";
    setState(() {
      messages.insert(0,message);
    });

    var url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": message.text
              }
            ]
          }
        ]
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      var botReply = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      setState(() {
        messages.insert(0,ChatMessage(
          text: botReply,
          user: bot,
          createdAt: DateTime.now(),
        ));
      });
    } else {
      setState(() {
        messages.insert(0,ChatMessage(
          text: 'Error: Unable to get a response.',
          user: bot,
          createdAt: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Chat Screen',
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
      body: Column(
        children:[
          Expanded(
            child: DashChat(
              inputOptions: InputOptions(
                sendButtonBuilder: (send) =>  InkWell(
                  onTap: send,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
        ,inputTextStyle: const TextStyle(color: Colors.white),inputDecoration: InputDecoration(
                isDense: true,
                hintText: 'Write a message...',
                hintStyle:const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xff424242),
                contentPadding: const EdgeInsets.only(
                  left: 18,
                  top: 10,
                  bottom: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
              ),),
              messageOptions: const MessageOptions(
                currentUserContainerColor: Colors.white38,
                currentUserTextColor: Colors.white,
              ),
              currentUser: user,
              onSend: (ChatMessage message) {
                sendMessage(message);
              },
              messages: messages,
            ),
          ),
        ],
      ),
    );
  }
}
