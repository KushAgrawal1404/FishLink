import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';

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

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();

  Future<void> _addCatch() async {
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    double basePrice = double.parse(_basePriceController.text.trim());
    int quantity = int.parse(_quantityController.text.trim());

    // Your add catch API endpoint
    String apiUrl = Api.addCatchUrl;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'name': name,
          // Add other fields here
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Catch added successfully
        // You can navigate to a different screen or show a success message
        Navigator.pop(context); // Close the add catch screen
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
              // Add more fields as needed
              ElevatedButton(
                onPressed: _addCatch,
                child: const Text('Add Catch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
