import 'package:swin/models/wood_database.dart';
import 'package:swin/models/wood_piece.dart';

class WoodRepository {
  Future<List<WoodDatabase>> getWoodDatabases() async {
    await Future.delayed(Duration(seconds: 1));

    return <WoodDatabase>[
      WoodDatabase(
        id: '1',
        cover: 'assets/images/wood_db_oak.png',
        title: 'Oak Database',
        description: 'A comprehensive database of oak wood species.',
        size: 10
      ),
    ];
  }

  Future<List<WoodPiece>> getWoodsList(int offset, int limit) async {
    await Future.delayed(Duration(seconds: 1));

    return <WoodPiece>[
      WoodPiece(
        id: "1",
        images : [],
        name: "Name",
        description: "description",
        origin: "origin",
        properties: ["properties"],
        relatedSpecies: ["relatedSpecies"]
      )
    ];
  }
}