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
        image: data['image'] ?? '',
        size: (data['size'] ?? 0) is int ? data['size'] : int.tryParse('${data['size']}') ?? 0,
      );
    }).toList();
  }

  Future<WoodPiece?> getWoodById(String id) async {
    final cleanId = id.trim();

    final doc = await _firestore
        .collection('wood_piece')
        .where('id', isEqualTo: cleanId)
        .get(const GetOptions(source: Source.server));

    final data = doc.docs.first.data();

    return WoodPiece(
      id: data['id'] ?? "",
      images: List<String>.from(data['image_urls'] ?? []),
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      origin: data['origin'] ?? '',
      properties: List<String>.from(data['properties'] ?? []),
      relatedSpecies: List<String>.from(data['relatedSpecies'] ?? []),
    );
  }


  Future<List<WoodPiece>> getWoodsList(String databaseId, int offset, int limit,) async {
    final snapshot = await _firestore
        .collection('wood_piece')
        .where('database_id', isEqualTo: databaseId.trim())
        .get(GetOptions(source: Source.server));

    print("vuha12: $databaseId");

    final docs = snapshot.docs;
    print("vuha12: docs length = ${docs.length}");
    return docs.map((doc) {
      final data = doc.data();
      print("vuha12: $data");

      return WoodPiece(
        id: data['id'] ?? doc.id,
        images: List<String>.from(data['image_urls'] ?? []),
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        origin: data['origin'] ?? '',
        properties: List<String>.from(data['properties'] ?? []),
        relatedSpecies: List<String>.from(data['relatedSpecies'] ?? []),
      );
    }).toList();
  }
}
