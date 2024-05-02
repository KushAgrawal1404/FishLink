import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';

class BuyerProfilePage extends StatefulWidget {
  const BuyerProfilePage({Key? key}) : super(key: key);

  @override
  _BuyerProfilePageState createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage> {
  Map<String, dynamic>? userProfile;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _harbourController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
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
          await http.get(Uri.parse('${Api.userProfileUrl}/user/$userId'));
      if (response.statusCode == 200) {
        await prefs.remove('userProfile');
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
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
        _isChanged = true; // Set _isChanged to true when image is changed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
      body: userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
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
                                ? NetworkImage(Api.baseUrl +
                                    userProfile![
                                        'profilePic']) // Use the correct URL here
                                : const AssetImage(
                                        'assets/default_profile_pic.png')
                                    as ImageProvider,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileItemBox(
                    Icons.person, 'Name', userProfile!['name']),
                _buildProfileItemBox(
                    Icons.email, 'Email', userProfile!['email']),
                _buildProfileItemBox(
                    Icons.phone, 'Phone', userProfile!['phone']),
                _buildEditableProfileItemWithEditButton(
                    Icons.book, 'Bio', _bioController),
                _buildEditableProfileItemWithEditButton(
                    Icons.location_on, 'Harbour', _harbourController),
                ElevatedButton(
                  onPressed: _isChanged
                      ? updateUserProfile
                      : null, // Disable button if nothing is changed
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileItemBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue), // Changed color to blue
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileItemWithEditButton(
      IconData icon, String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue), // Changed color to blue
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 0),
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: label,
                  ),
                  onChanged: (_) {
                    setState(() {
                      _isChanged = true;
                    });
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Edit $label'),
                    content: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: label,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          updateUserProfile();
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
