import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:myapp/screens/plant_detail_screen.dart';

import '../helpers/io_helpers.dart';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Plant>>(
        future: DatabaseHelper().getPlants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aun no hay plantas registradas.'));
          } else {
            List<Plant> plants = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(top: 25),
              child: ListView.builder(
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  Plant plant = plants[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 5,bottom: 5,right: 15,left: 15),
                    child: CardPlant(plant: plant),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class CardPlant extends StatelessWidget {
  final Plant plant;
  const CardPlant({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child:
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlantDetailScreen(plant: plant),
                ),
              );
            },
            leading: IOHelpers.getAvatar(plant.imagePath),
            title: Text(plant.name,style: TextTheme.of(context).headlineSmall,),
          ),
        ),
    );
  }
}