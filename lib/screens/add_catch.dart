import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fish_link/utils/api.dart'; // Import your API file
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

// Create a StatefulWidget for the AddCatchPage
class AddCatchPage extends StatefulWidget {
  const AddCatchPage({Key? key}) : super(key: key);

  @override
  State<AddCatchPage> createState() => _AddCatchPageState();
}

// Create the state class for AddCatchPage
class _AddCatchPageState extends State<AddCatchPage> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Variables for start and end time, and images
  DateTime? _startTime;
  DateTime? _endTime;
  List<XFile> images = <XFile>[];
  bool _isLoading = false; // To track loading state

  // Method to add catch
  Future<void> _addCatch(String email) async {
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    // Check for empty fields
    if (_nameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _basePriceController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty) {
      // If any field is empty, show snackbar and return
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Extract values from text fields
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    double? basePrice;
    int? quantity;

    try {
      // Parse base price and quantity
      basePrice = double.parse(_basePriceController.text.trim());
      quantity = int.parse(_quantityController.text.trim());

      // Check if base price is non-negative
      if (basePrice <= 0) {
        throw Exception('Base price must be greater than 0.');
      }

      // Check if quantity is non-negative
      if (quantity <= 0) {
        throw Exception('Quantity must be greater than 0.');
      }
    } catch (e) {
      // If parsing fails, show error message and return
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if start and end time are selected
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
        // Catch added successfully, show success snackbar and navigate back
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
      // If an error occurs during API call, show error message
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

  // Method to validate fields and show confirmation dialog
  void _validateAndShowConfirmationDialog(String email) {
    // Check for empty fields
    if (_nameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _basePriceController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _startTime == null ||
        _endTime == null ||
        images.isEmpty) {
      // If any field is empty, show snackbar and return
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill in all fields, select dates, and pick images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if end time is before start time
    if (_endTime!.isBefore(_startTime!)) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum auction duration is 1 min'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    _showConfirmationDialog(email);
  }

  // Method to show confirmation dialog
  Future<void> _showConfirmationDialog(String email) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to add this catch?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addCatch(email);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Method to load email from SharedPreferences
  Future<String> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  // Method to convert selected images to base64 format
  Future<List<String>> _getImages() async {
    List<String> imageList = [];

    for (var imageFile in images) {
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);
      imageList.add(base64Image);
    }

    return imageList;
  }

  // Method to select images using ImagePicker
  Future<void> _selectImages() async {
    final ImagePicker picker = ImagePicker();
    List<XFile>? imageFiles = await picker.pickMultiImage();

    setState(() {
      images = imageFiles ?? []; // Set selected images
    });
  }

  // Method to remove selected image
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

  // Method to select start time
  Future<void> _selectStartTime() async {
    final DateTime now = DateTime.now();
    final DateTime maxStartDate = now.add(const Duration(days: 2));

    DateTime initialDate = now;

    // Check if the current time is in the past
    if (_startTime != null && _startTime!.isAfter(now)) {
      initialDate = _startTime!;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      // Limit the maximum selectable start date to 2 days in advance
      lastDate: maxStartDate,
    );

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: now.hour, minute: now.minute), // Set initial time to now
      );

      if (timePicked != null) {
        final DateTime selectedDateTime = DateTime(picked.year, picked.month,
            picked.day, timePicked.hour, timePicked.minute);

        if (selectedDateTime.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a future date and time'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (selectedDateTime.isAfter(maxStartDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('You can only place catches up to 2 days in advance'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          setState(() {
            _startTime = selectedDateTime;
          });
        }
      }
    }
  }

  // Method to select end time
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

    final DateTime maxEndDate = _startTime!.add(const Duration(days: 3));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: _startTime ?? DateTime.now(),
      // Limit the maximum selectable end date to 3 days after the start date
      lastDate: maxEndDate,
    );

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (timePicked != null) {
        final DateTime selectedDateTime = DateTime(picked.year, picked.month,
            picked.day, timePicked.hour, timePicked.minute);

        if (selectedDateTime.isBefore(_startTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End date cannot be before start date'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (selectedDateTime.isAfter(maxEndDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'The difference between start and end dates must not exceed 3 days'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (selectedDateTime.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a future date and time'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          setState(() {
            _endTime = selectedDateTime;
          });
        }
      }
    }
  }

  // Method to format DateTime to a readable string
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
              // Text field for Name
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
              const SizedBox(height: 16), // Spacer
              // Text field for Location
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
              const SizedBox(height: 16), // Spacer
              // Text field for Base Price
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
              const SizedBox(height: 16), // Spacer
              // Text field for Quantity
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
              const SizedBox(height: 16), // Spacer
              // Button to select start date
              SizedBox(
                width: 400,
                height: 50,
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
              // Show start date if selected
              if (_startTime != null)
                Text('Start Date: ${formatDateTime(_startTime)}'),
              const SizedBox(height: 16), // Spacer
              // Button to select end date
              SizedBox(
                width: 400,
                height: 50,
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
              // Show end date if selected
              if (_endTime != null)
                Text('End Date: ${formatDateTime(_endTime)}'),
              const SizedBox(height: 16), // Spacer
              // Button to pick images
              SizedBox(
                width: 400,
                height: 50,
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
                    // List view to display selected images
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Image.file(File(images[index].path)),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Button to move image up
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: () {
                                  _moveImageUp(index);
                                },
                              ),
                              // Button to move image down
                              IconButton(
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: () {
                                  _moveImageDown(index);
                                },
                              ),
                              // Button to remove image
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
              const SizedBox(height: 16), // Spacer
              // Button to add catch
              FutureBuilder<String>(
                future: _loadEmail(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: 400,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _validateAndShowConfirmationDialog(snapshot.data!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Add Catch',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
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
