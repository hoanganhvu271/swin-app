import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swin/locators/swin_locators.dart';
import 'package:swin/ui/screens/main_screen.dart';
import 'onnx_predictor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final predictor = OnnxPredictor();
  // await predictor.initModel();
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

class PredictionWidget extends StatefulWidget {
  final OnnxPredictor predictor;

  const PredictionWidget({super.key, required this.predictor});

  @override
  State<PredictionWidget> createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget> {
  final List<String> classNames = [
    'Alantoma_decandra',
    'Caraipa_densifolia',
    'Cariniana_micrantha',
    'Caryocar_villosum',
    'Clarisia_racemosa',
    'Dipteryx_odorata',
    'Goupia_glabra',
    'Handroanthus_incanus',
    'Lueheopsis_duckeana',
    'Osteophloeum_platyspermum',
    'Pouteria_caimito',
  ];

  int predictionResult = -1;
  int? inferenceTimeMs; // thời gian dự đoán (ms)

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/test_image.png", width: 200, height: 200),
          SizedBox(height: 30),
          CustomButton(
            label: 'Predict',
            onTap: () async {
              final byteData = await rootBundle.load('assets/images/test_image.png');
              final bytes = byteData.buffer.asUint8List();

              // Bắt đầu đo thời gian
              final stopwatch = Stopwatch()..start();

              final result = await widget.predictor.predict(bytes);

              // Dừng stopwatch sau khi dự đoán xong
              stopwatch.stop();

              setState(() {
                predictionResult = result;
                inferenceTimeMs = stopwatch.elapsedMilliseconds;
              });
            },
          ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                'Class: ${predictionResult == -1 ? 'N/A' : classNames[predictionResult]}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              if (inferenceTimeMs != null)
                Text(
                  'Inference time: $inferenceTimeMs ms',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
            ],
          )
        ],
      ),
    );
  }
}


class CustomButton extends StatelessWidget {
  final String label;
  final Function()? onTap;

  const CustomButton({
    super.key,
    this.onTap,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
          child: Text(
            label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center
          ),
        ),
      ),
    );
  }
}
