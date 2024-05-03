import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fish_link/utils/api.dart';
import 'dart:convert';

class EditCatchPage extends StatefulWidget {
  final Map<String, dynamic> catchDetails;

  const EditCatchPage({Key? key, required this.catchDetails}) : super(key: key);

  @override
  State<EditCatchPage> createState() => _EditCatchPageState();
}

class _EditCatchPageState extends State<EditCatchPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.catchDetails['name'];
    _locationController.text = widget.catchDetails['location'];
    _basePriceController.text = widget.catchDetails['basePrice'].toString();
    _quantityController.text = widget.catchDetails['quantity'].toString();
    _startTimeController.text =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(widget.catchDetails['startTime']));
    _endTimeController.text =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(widget.catchDetails['endTime']));
  }

  Future<void> _selectStartTime(BuildContext context) async {
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
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
        setState(() {
          _startTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
        });
      }
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
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
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
        setState(() {
          _endTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    final String updatedName = _nameController.text;
    final String updatedLocation = _locationController.text;
    final double updatedBasePrice = double.parse(_basePriceController.text);
    final int updatedQuantity = int.parse(_quantityController.text);
    final String updatedStartTime = _startTimeController.text;
    final String updatedEndTime = _endTimeController.text;

    final Map<String, dynamic> updatedCatchData = {
      'name': updatedName,
      'location': updatedLocation,
      'basePrice': updatedBasePrice,
      'quantity': updatedQuantity,
      'startTime': updatedStartTime,
      'endTime': updatedEndTime,
    };

    String apiUrl = '${Api.editCatchUrl}/${widget.catchDetails['_id']}';

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

        Navigator.pop(context);
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectStartTime(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Select Start Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextFormField(
              controller: _startTimeController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Start Time'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectEndTime(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Select End Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextFormField(
              controller: _endTimeController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'End Time'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, 
                  backgroundColor: Colors.green.shade500, // Text color
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
