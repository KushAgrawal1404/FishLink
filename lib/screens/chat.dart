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

        // Print userId, senderId, receiverId, message, and timestamp for each message
        chatMessages!.forEach((message) {
          final senderId = message['senderId'];
          final messageText = message['message'];
          final timestamp = message['timestamp'];
          final receiverId = userId == winnerId ? sellerId : winnerId;
          print(
              'UserID: $userId, SenderID: $senderId, ReceiverID: $receiverId, Message: $messageText, Timestamp: $timestamp');
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
      //final receiverId = userId == winnerId ? sellerId : winnerId;

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

        final messageTimestamp = DateTime.now().toUtc().toIso8601String();
        print(
            'UserID: $userId, SenderID: $userId, Message: $messageText, Timestamp: $messageTimestamp');
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
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show a loading indicator
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (chatMessages != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: chatMessages!.length,
                    itemBuilder: (context, index) {
                      final message = chatMessages![index];
                      final isCurrentUser = message['senderId'] == userId;
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: ListTile(
                          title: Text(message['message']),
                          subtitle: Text(message['timestamp']),
                        ),
                      );
                    },
                  ),
                ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    messageText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                      // Save message to SharedPreferences
                      //saveDataToSharedPreferences('lastMessage', messageText!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
