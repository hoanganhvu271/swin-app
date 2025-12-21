abstract class HistoryEvent {}

class LoadHistory extends HistoryEvent {}

class ClearHistory extends HistoryEvent {}

class RemoveHistoryItem extends HistoryEvent {
  final String timestamp;

  RemoveHistoryItem(this.timestamp);
}