import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String catchId;

  ChatPage({Key? key, required this.catchId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? winnerId;
  String? sellerId;
  String? messageText;
  List<dynamic>? chatMessages;
  late String userId = ''; // User ID

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchWinnerDetails(widget.catchId);
  }

  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ??
          ''; // Replace 'userId' with your actual key
      print('UserID from SharedPreferences: $userId');
    });
  }

  Future<void> fetchWinnerDetails(String catchId) async {
    try {
      final response = await http.get(
        Uri.parse(Api.winDetailsUrl(widget.catchId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          final jsonData = jsonDecode(response.body);
          winnerId = jsonData['winnerId'];
          sellerId = jsonData['sellerId'];
          fetchChatMessages();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch winner details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching winner details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchChatMessages() async {
    try {
      final response = await http.get(
        Uri.parse(Api.getChatMessagesUrl(userId, widget.catchId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          chatMessages = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch chat messages'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching chat messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sendMessage() async {
    try {
      final response = await http.post(
        Uri.parse(Api.sendMessageUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': userId,
          'catchId': widget.catchId,
          'message': messageText,
        }),
      );

      if (response.statusCode == 201) {
        fetchChatMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Chat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final message = chatMessages![index];
                final senderId = message['senderId'];
                final messageText = message['message'];
                final isUser = senderId == userId;

                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Material(
                        color: isUser ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                        elevation: 6.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          child: Text(
                            messageText,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                onChanged: (String text) {
                  setState(() {
                    messageText = text;
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendMessage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
