class WoodDetailEvent {}

class GetWoodById extends WoodDetailEvent {
  final int woodId;

  GetWoodById(this.woodId);
}
