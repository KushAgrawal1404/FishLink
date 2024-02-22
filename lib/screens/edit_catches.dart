import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditCatchPage extends StatefulWidget {
  final Map<String, dynamic> catchDetails;

  const EditCatchPage({Key? key, required this.catchDetails}) : super(key: key);

  @override
  _EditCatchPageState createState() => _EditCatchPageState();
}

class _EditCatchPageState extends State<EditCatchPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.catchDetails['name'];
    locationController.text = widget.catchDetails['location'];
    basePriceController.text = widget.catchDetails['basePrice'].toString();
    quantityController.text = widget.catchDetails['quantity'].toString();
    startTimeController.text = widget.catchDetails['startTime'];
    endTimeController.text = widget.catchDetails['endTime'];
  }

  Future<void> _saveChanges() async {
    final String updatedName = nameController.text;
    final String updatedLocation = locationController.text;
    final double updatedBasePrice = double.parse(basePriceController.text);
    final int updatedQuantity = int.parse(quantityController.text);
    final String updatedStartTime = startTimeController.text;
    final String updatedEndTime = endTimeController.text;

    final Map<String, dynamic> updatedCatchData = {
      'name': updatedName,
      'location': updatedLocation,
      'basePrice': updatedBasePrice,
      'quantity': updatedQuantity,
      'startTime': updatedStartTime,
      'endTime': updatedEndTime,
      // Add other fields as needed
    };

    // Replace with your API endpoint for updating a catch
    String apiUrl = 'your_update_catch_api_url/${widget.catchDetails['id']}';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedCatchData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catch updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(
            context); // Navigate back to the previous page after successful update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update catch'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Catch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: basePriceController,
              decoration: const InputDecoration(labelText: 'Base Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time'),
            ),
            TextFormField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'End Time'),
            ),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
