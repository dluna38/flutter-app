import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:image_picker/image_picker.dart';

class AddPlantScreen extends StatelessWidget {
  const AddPlantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plant'),
        leading: const Icon(Icons.local_florist_outlined),
        backgroundColor: Colors.green[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            PlantForm(),
          ],
        ),
      ),
    );
  }
}

class PlantForm extends StatefulWidget {
  const PlantForm({super.key});

  @override
  State<PlantForm> createState() => _PlantFormState();
}

class _PlantFormState extends State<PlantForm> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  String? _imagePath;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imagePath = pickedFile.path;
      }
    });
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imagePath = pickedFile.path;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Plant Name')),
          const SizedBox(height: 16.0),
          TextField(controller: _speciesController, decoration: const InputDecoration(labelText: 'Plant Species')),
          const SizedBox(height: 16.0),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Plant Location')),
          const SizedBox(height: 24.0),
          ElevatedButton(onPressed: () async {
            final plant = Plant(name: _nameController.text, species: _speciesController.text, location: _locationController.text, notes: '', imagePath: _imagePath);
            await DatabaseHelper().insertPlant(plant);
            if (context.mounted) {
              Navigator.pop(context);
            }
          }, child: const Text('Save')),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: _takePhoto,
                child: const Text('Take Photo'),
              ),
            ],
          ),
           const SizedBox(height: 16.0),
          if (_imagePath != null)
            CircleAvatar(
              radius: 60,
              backgroundImage: FileImage(File(_imagePath!)),
            ),
        ],
      );
  }
}