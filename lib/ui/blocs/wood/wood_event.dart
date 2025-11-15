class WoodEvent {}

class GetWoodListEvent extends WoodEvent {
  final String databaseId;

  GetWoodListEvent(this.databaseId);
}
