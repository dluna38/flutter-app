import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:myapp/screens/plant_detail_screen.dart';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant List'),
        leading: const Icon(
          Icons.local_florist,
        ),
      ),
      body: FutureBuilder<List<Plant>>(
        future: DatabaseHelper().getPlants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No plants added yet.'));
          } else {
            List<Plant> plants = snapshot.data!;
            return ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                Plant plant = plants[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlantDetailScreen(plant: plant)),
                    );
                  },
                  child: Row(
                    children: [
                      plant.imagePath != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(plant.imagePath!)),
                              radius: 30,
                            )
                          : const CircleAvatar(
                              backgroundImage:
                                  AssetImage('web/favicon.png'),
                              radius: 30,
                            ),
                      const SizedBox(width: 10),
                      Text(plant.name),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}