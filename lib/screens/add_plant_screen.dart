import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/helpers/string_helpers.dart';

import '../main.dart';

class AddPlantScreen extends StatelessWidget {
  const AddPlantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar planta'),
        centerTitle: true,
        //leading: const Icon(Icons.local_florist_outlined),
        backgroundColor: Colors.green[300],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [FormPlant()],
          ),
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
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Plant Name'),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _speciesController,
          decoration: const InputDecoration(labelText: 'Plant Species'),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Plant Location'),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: () async {
            final plant = Plant(
              name: _nameController.text,
              species: _speciesController.text,
              location: _locationController.text,
              notes: '',
              imagePath: _imagePath,
            );
            await DatabaseHelper().insertPlant(plant);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
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

class FormPlant extends StatefulWidget {
  const FormPlant({super.key});

  @override
  State<FormPlant> createState() => _FormPlantState();
}

class _FormPlantState extends State<FormPlant> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final hintStyle = TextStyle(color: Colors.grey[400]);

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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _imagePath == null
              ? Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                    style:
                        BorderStyle
                            .solid, // Para hacerla punteada, se necesitaría un package o un CustomPainter
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: _takePhoto,
                          icon: Icon(Icons.photo_camera),
                        ),
                        Text(
                          'Tomar foto',
                          style: TextTheme.of(context).labelSmall,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 55,
                          image: AssetImage('resources/placeholder-img.jpg'),
                        ),
                        Text(
                          'Agregar imagen',
                          style: TextTheme.of(context).headlineSmall,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: _getImage,
                          icon: Icon(Icons.photo_library),
                        ),
                        Text(
                          'Galeria',
                          style: TextTheme.of(context).labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  Center(
                    child: Image(
                      image: FileImage(File(_imagePath!)),
                      height: 180,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      // Material para efecto ripple en el IconButton
                      color: Colors.transparent,
                      child: IconButton.filled(
                        onPressed: () {
                          debugPrint('close');
                          setState(() {
                            _imagePath = null;
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
                    ),
                  ),
                ],
              ),
          SizedBox(height: 25),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre de la planta',
              hintText: 'Carnivorita...',
              hintStyle: hintStyle,
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'No puedes dejarlo vacio';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _speciesController,
            decoration: InputDecoration(
              labelText: 'Especie de la planta',
              hintText: 'Dionea muscipula',
              hintStyle: hintStyle,
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'No puedes dejarlo vacio';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Ubicación de la planta',
              hintText: 'Terraza, esquina, p2...',
              hintStyle: hintStyle,
            ),
          ),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Notas adicionales',
              hintText: 'Regar solo con agua de lluvia',
              hintStyle: hintStyle,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    final plant = Plant(
                      name: _nameController.text,
                      species: _speciesController.text,
                      location:
                          _locationController.text.isEmpty
                              ? StringHelpers.NO_LOCATION_PLANT
                              : _locationController.text,
                      notes:
                          _notesController.text.isEmpty
                              ? null
                              : _notesController.text,
                      imagePath: _imagePath,
                    );
                    debugPrint('Guardar: $plant');
                    await DatabaseHelper().insertPlant(plant);
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
