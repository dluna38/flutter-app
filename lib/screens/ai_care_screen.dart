import 'dart:core';

import 'package:flutter/material.dart';
import 'package:myapp/helpers/ai_helper.dart';

class AiCareFormScreen extends StatefulWidget {
  final String plantCommonName;
  final String? species;
  const AiCareFormScreen({super.key, required this.plantCommonName, this.species});

  @override
  State<AiCareFormScreen> createState() => _AiCareFormScreenState();
}

class _AiCareFormScreenState extends State<AiCareFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plantCommonNameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _aiNotes = '';
  bool _isSearching = false;
  int _searchCount = 0;
  static const int maxSearchesPerDay = 3;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    if(widget.plantCommonName.isNotEmpty){
      _plantCommonNameController.text = widget.plantCommonName;
    }
    if(widget.species != null && widget.species!.isNotEmpty){
      _speciesController.text = widget.species!;
    }
  }

  @override
  void dispose() {
    _plantCommonNameController.dispose();
    _speciesController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchAiResponse() async {
    if (_searchCount >= maxSearchesPerDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Has alcanzado el límite de 3 búsquedas por día.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSearching = true;
      });

      String userMessage = AiHelper().createUserMessage(_plantCommonNameController.text, _speciesController.text, _locationController.text);
      AiResponse response = await AiHelper().getChatCompletion(userMessage);

      if(!response.result){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Servicio no disponible, intentalo mas tarde')),
        );
        return;
      }

      setState(() {
        _aiNotes = response.response!;
        _notesController.text = _aiNotes;
        _isSearching = false;
        _searchCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar cuidados con IA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _plantCommonNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre común de la planta',
                    hintText: 'Ej: Lengua de suegra',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el nombre de la planta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Especie',
                    hintText: 'Ej: Sansevieria trifasciata',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    hintText: 'Ej: Colombia',
                  ),
                ),
                const SizedBox(height: 24),
                // Campo de texto para las notas generadas por la IA
                SizedBox(
                  height: 200,
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: null, // Permite que el texto se expanda verticalmente
                    expands: true, // El widget ocupa todo el espacio del padre
                    readOnly: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Cuidados (Generado por IA)',
                      hintText: 'Aquí aparecerán los cuidados de la planta...',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botones dinámicos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_aiNotes.isEmpty)
                      ElevatedButton(
                        onPressed: _isSearching ? null : _fetchAiResponse,
                        child: _isSearching
                            ? const CircularProgressIndicator()
                            : const Text('Buscar'),
                      ),
                    if (_aiNotes.isNotEmpty) ...[
                      ElevatedButton.icon(
                        onPressed: (){
                          Navigator.pop(context,_aiNotes);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Seleccionar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _searchCount < maxSearchesPerDay
                            ? _isSearching ? null : _fetchAiResponse
                            : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generar otra vez'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Búsquedas restantes hoy: ${maxSearchesPerDay - _searchCount}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}