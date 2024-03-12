// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fish_link/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AddCatchPage extends StatefulWidget {
  const AddCatchPage({Key? key}) : super(key: key);

  @override
  State<AddCatchPage> createState() => _AddCatchPageState();
}

class _AddCatchPageState extends State<AddCatchPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;
  List<XFile> images = <XFile>[];

  Future<void> _addCatch(String email) async {
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    double basePrice = double.parse(_basePriceController.text.trim());
    int quantity = int.parse(_quantityController.text.trim());

    // Check if start time and end time are selected
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start time and end time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Your add catch API endpoint
    String apiUrl = Api.addCatchUrl;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'name': name,
          'email': email,
          'location': location,
          'basePrice': basePrice,
          'quantity': quantity,
          'startTime': _startTime!.toIso8601String(),
          'endTime': _endTime!.toIso8601String(),
          'images': await _getImages(), // Encode images to base64
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Catch added successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added catch'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        // Catch addition failed, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add catch'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectStartTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          _startTime = DateTime(picked.year, picked.month, picked.day,
              timePicked.hour, timePicked.minute);
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          _endTime = DateTime(picked.year, picked.month, picked.day,
              timePicked.hour, timePicked.minute);
        });
      }
    }
  }

  Future<String> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  Future<List<String>> _getImages() async {
    List<String> imageList = [];

    for (var imageFile in images) {
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);
      imageList.add(base64Image);
    }

    return imageList;
  }

  Future<void> _selectImages() async {
    final ImagePicker picker = ImagePicker();
    List<XFile>? imageFiles = await picker.pickMultiImage();

    setState(() {
      images = imageFiles;
    });
  }

  void _removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  // Method to move the image up in the list
  void _moveImageUp(int index) {
    if (index > 0) {
      setState(() {
        final XFile image = images.removeAt(index);
        images.insert(index - 1, image);
      });
    }
  }

  // Method to move the image down in the list
  void _moveImageDown(int index) {
    if (index < images.length - 1) {
      setState(() {
        final XFile image = images.removeAt(index);
        images.insert(index + 1, image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Catch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _basePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Base Price'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 16),
              // Start Time Picker
              ElevatedButton(
                onPressed: _selectStartTime,
                child: const Text('Select Start Time'),
              ),
              if (_startTime != null) Text('Start Time: $_startTime'),
              const SizedBox(height: 16),
              // End Time Picker
              ElevatedButton(
                onPressed: _selectEndTime,
                child: const Text('Select End Time'),
              ),
              if (_endTime != null) Text('End Time: $_endTime'),
              const SizedBox(height: 16),
              // Image Picker
              ElevatedButton(
                onPressed: _selectImages,
                child: const Text('Pick Images'),
              ),
              // Display selected images
              if (images.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Selected Images:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Image.file(File(images[index].path)),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: () {
                                  _moveImageUp(index);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: () {
                                  _moveImageDown(index);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  _removeImage(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Fetch email from SharedPreferences
              FutureBuilder<String>(
                future: _loadEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ElevatedButton(
                      onPressed: () {
                        _addCatch(snapshot.data!);
                      },
                      child: const Text('Add Catch'),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//checking m