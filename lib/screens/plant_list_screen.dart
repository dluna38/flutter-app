import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/data/database_helper.dart';
import 'package:myapp/data/plant.dart';
import 'package:myapp/screens/detail_plant_screen.dart';

import 'package:myapp/helpers/io_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_plant_screen.dart';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Object>>(
        future: Future.wait([
          DatabaseHelper().getPlants(),
          SharedPreferences.getInstance().then(
            (prefs) => prefs.getString('view_mode') ?? 'list',
          ),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data![0] as List).isEmpty) {
            return const Center(child: Text('Aun no hay plantas registradas.'));
          } else {
            List<Plant> plants = snapshot.data![0] as List<Plant>;
            String viewMode = snapshot.data![1] as String;

            return Padding(
              padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
              child: _buildPlantList(plants, viewMode),
            );
          }
        },
      ),
    );
  }

  Widget _buildPlantList(List<Plant> plants, String viewMode) {
    if (viewMode == 'grid_image') {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return _buildGridImageCard(plants[index]);
        },
      );
    } else if (viewMode == 'grid_text') {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return _buildGridTextCard(plants[index]);
        },
      );
    } else {
      // Default List View
      return ListView.builder(
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: cardPlant(plants[index]),
          );
        },
      );
    }
  }

  Widget _buildGridImageCard(Plant plant) {
    return GestureDetector(
      onTap: () => _navigateToDetail(plant),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            plant.imagePath != null
                ? Image.file(File(plant.imagePath!), fit: BoxFit.cover)
                : Image.asset(
                  IOHelpers.getImagePlaceHolderString(),
                  fit: BoxFit.cover,
                ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                plant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTextCard(Plant plant) {
    return GestureDetector(
      onTap: () => _navigateToDetail(plant),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_florist,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                plant.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(Plant plant) async {
    PlantResult? result = await Navigator.push<PlantResult>(
      context,
      MaterialPageRoute<PlantResult>(
        builder: (context) => PlantDetailScreen(plant: plant),
      ),
    );
    if (result != null && result.updated) {
      setState(() {
        // Trigger rebuild to refresh list
      });
    }
  }

  Widget cardPlant(Plant plant) {
    return Card(
      //color: Theme.of(context).colorScheme.onSurface.withValues(a),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 16.0,
        ),
        onTap: () => _navigateToDetail(plant),
        leading: IOHelpers.getAvatar(plant.imagePath),
        title: Text(plant.name, style: TextTheme.of(context).headlineSmall),
      ),
    );
  }
}
