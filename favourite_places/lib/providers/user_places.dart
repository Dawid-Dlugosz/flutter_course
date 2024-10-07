import 'dart:io';

import 'package:favourite_places/models/place.dart';
import 'package:riverpod/riverpod.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

Future<sqflite.Database> _getDatabase() async {
  final dpPath = await sqflite.getDatabasesPath();
  final db = await sqflite.openDatabase(
    path.join(dpPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE places (id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  Future<void> loadData() async {
    final db = await _getDatabase();
    final data = await db.query('places');
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            placeLocation: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();

    state = places;
  }

  void addPlace(String title, File? image, PlaceLocation placeLocation) async {
    final appDir = await pathProvider.getApplicationDocumentsDirectory();
    final fileNmae = path.basename(image!.path);
    final newImagePath = '${appDir.path}/$fileNmae';

    final copiedImage = await image.copy(newImagePath);

    final newPlace = Place(
      title: title,
      image: copiedImage,
      placeLocation: placeLocation,
    );

    final db = await _getDatabase();

    db.insert('places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': copiedImage.path,
      'lat': newPlace.placeLocation.latitude,
      'lng': newPlace.placeLocation.longitude,
      'address': newPlace.placeLocation.address,
    });

    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
        (refs) => UserPlacesNotifier());
