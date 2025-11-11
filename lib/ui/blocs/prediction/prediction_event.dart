part of 'prediction_bloc.dart';

class PredictionEvent {}

class PredictionReset extends PredictionEvent {}

class PredictionRequested extends PredictionEvent {}

class PredictionInputChanged extends PredictionEvent {
  final File input;

  PredictionInputChanged(this.input);
}

class PredictionModelLoaded extends PredictionEvent {
  final AiModel model;

  PredictionModelLoaded(this.model);
}

class InitRuntimeRequested extends PredictionEvent {}

class PredictionModelListFetched extends PredictionEvent {}
