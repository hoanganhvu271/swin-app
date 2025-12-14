import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPaperScreen extends StatelessWidget {
  const ViewPaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài báo khoa học'), backgroundColor: Colors.white),
      body: SfPdfViewer.asset(
        'assets/pdfs/paper.pdf',
      ),
    );
  }
}
