import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/helpers/string_helpers.dart';
import 'package:myapp/screens/ai_care_screen.dart';

class AddPlantScreen extends StatelessWidget {
  final Plant? updatePlant;
  const AddPlantScreen({super.key, this.updatePlant});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && context.mounted) {
          Navigator.pop(context, PlantResult());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${updatePlant == null ? 'Agregar' : 'Editar'} planta'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.pop(context, PlantResult());
            },
          ),
          backgroundColor: colorScheme.surface,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [FormPlant(updatePlant: updatePlant)],
            ),
          ),
        ),
      ),
    );
  }
}

class FormPlant extends StatefulWidget {
  final Plant? updatePlant;
  const FormPlant({super.key, this.updatePlant});

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
  DateTime? _selectedDate;
  String? _imagePath;

  late final Plant? oldPlant;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.updatePlant != null) {
      oldPlant = widget.updatePlant!;

      debugPrint("update: ${widget.updatePlant!.id}");

      _nameController.text = oldPlant!.name;
      _speciesController.text = oldPlant!.species ?? "";
      _locationController.text = oldPlant!.location ?? "";
      _notesController.text = oldPlant!.notes ?? "";
      _selectedDate = oldPlant!.acquisitionDate;
      _imagePath = oldPlant!.imagePath;
    } else {
      oldPlant = null;
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxHeight: 512,
      requestFullMetadata: false
    );

    setState(() {
      if (pickedFile != null) {
        _imagePath = pickedFile.path;
      }
    });
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera,imageQuality: 70,maxHeight: 512,requestFullMetadata: false);
    setState(() {
      if (pickedFile != null) {
        _imagePath = pickedFile.path;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      debugPrint('Guardar: $picked');
      setState(() {
        _selectedDate = picked;
      });
    }
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
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[300]
                          : Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
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
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 55,
                            image: AssetImage('resources/placeholder-img.jpg'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
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
          const SizedBox(height: 25),
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
          Row(
            children: [
              Text(
                'Fecha de adquisición: ${_selectedDate != null ? DateFormat('dd-MM-yyyy').format(_selectedDate!) : ''}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Notas / Cuidados',
              hintText: 'Regar solo con agua de lluvia',
              hintStyle: hintStyle,
              suffixIcon: IconButton(
                icon: Icon(Icons.auto_fix_high), // Icono de IA, por ejemplo
                onPressed: () async {
                  if(!_formKey.currentState!.validate()){
                    return;
                  }
                  String? text = await Navigator.push<String?>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AiCareFormScreen(
                            plantCommonName: _nameController.text,
                            species: _speciesController.text,
                          ),
                    ),
                  );
                  if (text != null) {
                    _notesController.text = text;
                  }
                },
              ),
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
                      name: _nameController.text.trim(),
                      species: _speciesController.text.trim(),
                      location:
                          _locationController.text.isEmpty
                              ? StringHelpers.NO_LOCATION_PLANT
                              : _locationController.text.trim(),
                      notes:
                          _notesController.text.isEmpty
                              ? null
                              : _notesController.text.trim(),
                      imagePath: _imagePath,
                      acquisitionDate: _selectedDate,
                    );

                    debugPrint(
                      'Guardar: $plant ${oldPlant != null ? ' update' : ''}',
                    );

                    try {
                      if (oldPlant != null) {
                        await DatabaseHelper().updatePlant(plant, oldPlant!);
                      } else {
                        await DatabaseHelper().insertPlant(plant);
                      }
                    } catch (e) {
                      debugPrint(e as String?);
                    }
                    if (context.mounted) {
                      if (oldPlant != null) {
                        Navigator.pop(context, PlantResult(updated: true));
                      } else {
                        Navigator.pop(context, PlantResult(created: true));
                      }
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

class PlantResult {
  final bool created;
  final bool updated;

  PlantResult({this.created = false, this.updated = false});
}
