class WoodDetailEvent {}

class GetWoodById extends WoodDetailEvent {
  final String woodId;

  GetWoodById(this.woodId);
}
