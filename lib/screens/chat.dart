import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'dart:convert'; // Import convert for JSON parsing
import 'package:fish_link/utils/api.dart'; // Import your API class

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

  @override
  void initState() {
    super.initState();
    fetchWinnerDetails(widget.catchId);
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
        // Check if winnerId and sellerId are not null
        final response = await http.get(
          Uri.parse(Api.getChatMessagesUrl(winnerId!,
              sellerId!)), // Use ! to assert that these variables are not null
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
          'senderId': winnerId, // Replace userId with appropriate value
          'receiverId': sellerId, // Replace receiverId with appropriate value
          'message': messageText,
        }),
      );

      if (response.statusCode == 201) {
        // Message sent successfully, update chat
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
                    return ListTile(
                      title: Text(chatMessages![index]['message']),
                      // No longer displaying sender's ID
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
