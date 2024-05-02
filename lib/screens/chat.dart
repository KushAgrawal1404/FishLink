import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchWinnerDetails(widget.catchId);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
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
        // Clear the message text after sending
        setState(() {
          messageText = '';
          _textController.clear();
        });
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
        title: Text('Chat'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                final timestamp = message['timestamp'];
                final isUser = senderId == userId;

                DateTime dateTime = DateTime.parse(timestamp);
                String time = DateFormat('hh:mm a').format(dateTime);

                // Check if the current message's date is different from the previous message's date
                bool showDateSeparator = false;
                if (index == 0 ||
                    _isDifferentDate(
                        chatMessages![index - 1]['timestamp'], timestamp)) {
                  showDateSeparator = true;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDateSeparator)
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 2, 2, 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(dateTime),
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      ),
                    Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Color.fromARGB(255, 33, 141, 229)
                                  .withOpacity(0.9)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(3, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageText,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              time,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.teal),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          messageText = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(Icons.send),
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isDifferentDate(String prevTimestamp, String currentTimestamp) {
    DateTime prevDate = DateTime.parse(prevTimestamp);
    DateTime currentDate = DateTime.parse(currentTimestamp);
    return prevDate.year != currentDate.year ||
        prevDate.month != currentDate.month ||
        prevDate.day != currentDate.day;
  }
}
