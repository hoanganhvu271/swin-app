import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swin/models/wood_database.dart';
import 'package:swin/models/wood_piece.dart';

class WoodRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<List<WoodDatabase>> getWoodDatabases() async {
    final snapshot = await _firestore.collection('wood_database').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      print("vuha12: $data");
      return WoodDatabase(
        id: data['id'] ?? doc.id,
        cover: data['cover'] ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        size: (data['size'] ?? 0) is int ? data['size'] : int.tryParse('${data['size']}') ?? 0,
      );
    }).toList();
  }

  Future<List<WoodPiece>> getWoodsList(int offset, int limit) async {
    final snapshot = await _firestore
        .collection('wood_piece')
        .orderBy('id')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      print(data);
      return WoodPiece(
        id: data['id'] ?? doc.id,
        images: List<String>.from(data['images'] ?? []),
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        origin: data['origin'] ?? '',
        properties: List<String>.from(data['properties'] ?? []),
        relatedSpecies: List<String>.from(data['relatedSpecies'] ?? []),
      );
    }).toList();
  }
}
