import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fish_link/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AddCatchPage extends StatefulWidget {
  const AddCatchPage({Key? key}) : super(key: key);

  @override
  _AddCatchPageState createState() => _AddCatchPageState();
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
          ),
        );
      } else {
        // Catch addition failed, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add catch'),
          ),
        );
      }
    } catch (e) {
      // Error occurred during catch addition
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
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
