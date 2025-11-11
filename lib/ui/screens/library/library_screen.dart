import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Text("Thu vien"),
              WoodDatabaseBanner()
            ],
          )
        ),
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
