import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swin/locators/swin_locators.dart';
import 'package:swin/ui/screens/prediction/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initSwinLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: [SystemUiOverlayStyle.light, SystemUiOverlayStyle.dark],
      child: MaterialApp(
        color: Colors.white,
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: MainScreen(),
        ),
      ),
    );
  }
}
