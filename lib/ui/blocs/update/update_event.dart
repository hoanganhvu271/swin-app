import 'package:equatable/equatable.dart';

abstract class UpdateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckVersionEvent extends UpdateEvent {}

class DownloadModelEvent extends UpdateEvent {}
