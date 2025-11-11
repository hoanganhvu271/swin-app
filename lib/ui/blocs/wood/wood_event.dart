class WoodEvent {}

class GetWoodListEvent extends WoodEvent {
  final String databaseIds;

  GetWoodListEvent(this.databaseIds);
}
