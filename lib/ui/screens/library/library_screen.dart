import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/ui/blocs/library/library_bloc.dart';
import 'package:swin/ui/blocs/library/library_state.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryBloc>(
      create: (_) => LibraryBloc(),
      child: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          return Material(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  Text("Thu vien"),
                  WoodDatabaseBanner()
                ],
              )
            ),
          );
        }
      ),
    );
  }
}

class WoodDatabaseBanner extends StatelessWidget {
  const WoodDatabaseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/images/wood_database.png"),
        const Text("Wood Database 1"),
        const Text("Wood Database Description"),
      ],
    );
  }
}
