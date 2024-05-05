// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fish_link/utils/api.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = false;

  Future<void> _addCatch(String email) async {
    setState(() {
      _isLoading = true;
    });
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    double basePrice = double.parse(_basePriceController.text.trim());
    int quantity = int.parse(_quantityController.text.trim());

    // Check if start time and end time are selected
    if (_startTime == null || _endTime == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date and end date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if end time is before start time
    if (_endTime!.isBefore(_startTime!)) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if the difference between start time and end time is less than 1 minute
    if (_endTime!.difference(_startTime!).inMinutes < 1) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum auction duration is 1 min'),
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
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add catch'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
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
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the start date first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: _startTime ?? DateTime.now(),
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

  String? formatDateTime(DateTime? datetime) {
    if (datetime == null) {
      return null; // Return null if datetime is null
    }
    DateFormat formatter = DateFormat('dd-MM-yyyy h:mma');
    DateTime localDatetime = datetime.toLocal();
    return formatter.format(localDatetime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Catch'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 18.0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter location',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 18.0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _basePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Base Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter base price',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 18.0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity (in kgs)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter quantity',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 18.0),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: 400, // <-- Your width
                height: 50, // <-- Your height
                child: ElevatedButton(
                  onPressed: _selectStartTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Select Start Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (_startTime != null)
                Text('Start Date: ${formatDateTime(_startTime)}'),
              const SizedBox(height: 16),
              SizedBox(
                width: 400, // <-- Your width
                height: 50, // <-- Your height
                child: ElevatedButton(
                  onPressed: _selectEndTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Select End Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (_endTime != null)
                Text('End Date: ${formatDateTime(_endTime)}'),
              const SizedBox(height: 16),
              SizedBox(
                width: 400, // <-- Your width
                height: 50, // <-- Your height
                child: ElevatedButton(
                  onPressed: _selectImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pick Images',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
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
              FutureBuilder<String>(
                future: _loadEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SizedBox(
                      width: 400, // <-- Your width
                      height: 50, // <-- Your height
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _addCatch(snapshot.data!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade500,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add Catch',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
