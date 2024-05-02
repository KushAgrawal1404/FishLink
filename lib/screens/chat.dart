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
  late String
      userIdFromPreferences; // Assuming you have stored userId in preferences

  @override
  void initState() {
    super.initState();
    fetchUserIdFromPreferences();
    fetchWinnerDetails(widget.catchId);
  }

  Future<void> fetchUserIdFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userIdFromPreferences = prefs.getString('userId') ??
          ''; // Replace 'userId' with your actual key
    });
  }

  Future<void> fetchWinnerDetails(String catchId) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.winDetailsUrl(widget.catchId)}'),
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
      if (winnerId != null && sellerId != null) {
        final response = await http.get(
          Uri.parse(Api.getChatMessagesUrl(winnerId!, sellerId!)),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Winner ID or Seller ID is null'),
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
          'senderId': winnerId,
          'receiverId': sellerId,
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

  // Function to save data to SharedPreferences
  Future<void> saveDataToSharedPreferences(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (userIdFromPreferences == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          backgroundColor: Colors.transparent,
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
                      final isCurrentUser =
                          message['senderId'] == userIdFromPreferences;
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
                      saveDataToSharedPreferences('lastMessage', messageText!);
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
