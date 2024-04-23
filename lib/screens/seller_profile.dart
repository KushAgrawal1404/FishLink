import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({Key? key}) : super(key: key);

  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  Map<String, dynamic>? userProfile;
  TextEditingController _bioController = TextEditingController();
  TextEditingController _harbourController = TextEditingController();
  String? _selectedImagePath;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    try {
      final response =
          await http.get(Uri.parse('${Api.userProfileUrl}/seller/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
          _bioController.text = userProfile!['bio'] ?? '';
          _harbourController.text = userProfile!['harbour'] ?? '';
        });
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: userProfile == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 250,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _selectedImagePath != null
                              ? FileImage(File(_selectedImagePath!))
                              : userProfile!['profilePic'] != null &&
                                      userProfile!['profilePic'] != ''
                                  ? NetworkImage(userProfile![
                                      'profilePic']) // Use the correct URL here
                                  : AssetImage('assets/default_profile_pic.png')
                                      as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildProfileItemBox('Name', userProfile!['name']),
                  _buildProfileItemBox('Email', userProfile!['email']),
                  _buildProfileItemBox('Phone', userProfile!['phone']),
                  _buildEditableProfileItemBox('Bio', _bioController),
                  _buildEditableProfileItemBox('Harbour', _harbourController),
                  ElevatedButton(
                    onPressed: _isChanged
                        ? updateUserProfile
                        : null, // Disable button if nothing is changed
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItemBox(String label, String value) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '$value',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableProfileItemBox(
      String label, TextEditingController controller) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Edit $label'),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: label,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            setState(() {
                              _isChanged = true;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: _isChanged
                                ? () {
                                    updateUserProfile();
                                    Navigator.pop(context);
                                  }
                                : null,
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              controller.text,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    try {
      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'bio': _bioController.text,
        'harbour': _harbourController.text,
      };

      // If a new image is selected, include it in the request
      if (_selectedImagePath != null) {
        List<int> imageBytes = File(_selectedImagePath!).readAsBytesSync();
        String base64Image = base64Encode(imageBytes);
        requestBody['profilePic'] = base64Image;
      }

      final response = await http.post(
        Uri.parse('${Api.userProfileUrl}/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        setState(() {
          userProfile!['bio'] = _bioController.text;
          userProfile!['harbour'] = _harbourController.text;
          if (_selectedImagePath != null) {
            userProfile!['profilePic'] = _selectedImagePath;
          }
          _isChanged = false; // Reset _isChanged when profile is updated
        });
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (error) {
      print('Error updating user profile: $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
        _isChanged = true; // Set _isChanged to true when image is changed
      });
    }
  }
}
