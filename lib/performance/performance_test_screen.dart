// screens/performance_test_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../performance/model_loader_with_metrics.dart';
import '../performance/inference_tester.dart';
import 'device_info.dart';
import 'inference_metrics.dart';

class PerformanceTestScreen extends StatefulWidget {
  const PerformanceTestScreen({super.key});

  @override
  _PerformanceTestScreenState createState() => _PerformanceTestScreenState();
}

class _PerformanceTestScreenState extends State<PerformanceTestScreen> {
  bool _isTesting = false;
  String _status = 'Ready to test';
  double _progress = 0.0;

  // Kết quả
  int? _modelLoadingTimeMs;
  InferenceMetrics? _inferenceMetrics;
  String? _deviceInfo;

  // Model và ảnh test
  Uint8List? _modelBytes;
  late Uint8List _testImageBytes;

  // Lựa chọn model
  String _selectedModel = 'small_yolo.onnx';
  final List<String> _availableModels = [
    'small_yolo.onnx',
    'big_yolo.onnx',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialAssets();
  }

  Future<void> _loadInitialAssets() async {
    try {
      // Load model mặc định
      await _loadSelectedModel();

      // Load ảnh test từ assets
      _testImageBytes = (await rootBundle.load('assets/images/test_performance.jpg'))
          .buffer
          .asUint8List();

      setState(() {
        _status = 'Assets loaded successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading assets: $e';
      });
    }
  }

  Future<void> _loadSelectedModel() async {
    try {
      _modelBytes = (await rootBundle.load('assets/models/$_selectedModel'))
          .buffer
          .asUint8List();
    } catch (e) {
      setState(() {
        _status = 'Error loading model $_selectedModel: $e';
      });
      rethrow;
    }
  }

  Future<void> _onModelChanged(String? newModel) async {
    if (newModel == null || newModel == _selectedModel) return;

    setState(() {
      _selectedModel = newModel;
      _status = 'Loading model $newModel...';

      // Reset kết quả cũ
      _modelLoadingTimeMs = null;
      _inferenceMetrics = null;
    });

    try {
      await _loadSelectedModel();
      setState(() {
        _status = 'Model $newModel loaded successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to load $newModel: $e';
      });
    }
  }

  Future<void> _runPerformanceTest() async {
    if (_isTesting || _modelBytes == null) return;

    setState(() {
      _isTesting = true;
      _progress = 0.0;
      _status = 'Initializing...';
    });

    ModelLoaderWithMetrics? modelLoader;
    InferenceTester? inferenceTester;

    try {
      // === BƯỚC 1: LOAD MODEL ===
      setState(() {
        _status = 'Loading $_selectedModel with timing...';
        _progress = 0.1;
      });

      modelLoader = ModelLoaderWithMetrics();
      final session = await modelLoader.loadModelWithTiming(
        modelBytes: _modelBytes!,
        enableOptimizations: true,
        logToConsole: true,
      );

      _modelLoadingTimeMs = modelLoader.loadingTimeMs;

      // === BƯỚC 2: KHỞI TẠO INFERENCE TESTER ===
      setState(() {
        _status = 'Preparing inference tester...';
        _progress = 0.3;
      });

      inferenceTester = InferenceTester(
        session: session,
        testImageBytes: _testImageBytes,
      );

      // === BƯỚC 3: WARMUP ===
      setState(() {
        _status = 'Running warmup (3 runs)...';
        _progress = 0.5;
      });

      await inferenceTester.performWarmup(runs: 3);

      // === BƯỚC 4: ĐO HIỆU NĂNG CHÍNH THỨC ===
      setState(() {
        _status = 'Measuring inference time (10 runs)...';
        _progress = 0.7;
      });

      _inferenceMetrics = await inferenceTester.performMeasurement(runs: 10);

      // === BƯỚC 5: HOÀN THÀNH ===
      setState(() {
        _status = 'Test completed successfully!';
        _progress = 1.0;
      });

      // Lấy device info
      _deviceInfo = await getDeviceInfoString();

    } catch (e) {
      setState(() {
        _status = 'Test failed: $e';
        _isTesting = false;
      });
    } finally {
      // Cleanup
      modelLoader?.close();

      setState(() {
        _isTesting = false;
      });
    }
  }

  Widget _buildModelSelectionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🤖 Model Selection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),

            // Dropdown chọn model
            DropdownButtonFormField<String>(
              value: _selectedModel,
              decoration: InputDecoration(
                labelText: 'Select Model',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.model_training),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _availableModels.map((String model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Row(
                    children: [
                      Icon(
                        model == 'small_yolo.onnx'
                            ? Icons.lightbulb_outline
                            : Icons.lightbulb,
                        color: model == 'small_yolo.onnx'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      SizedBox(width: 10),
                      Text(model),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _onModelChanged,
              isExpanded: true,
            ),

            SizedBox(height: 12),

            // Thông tin model hiện tại
            if (_modelBytes != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected: $_selectedModel',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Size: ${_modelBytes!.length ~/ 1024} KB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    if (_modelLoadingTimeMs == null || _inferenceMetrics == null) {
      return SizedBox();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '📊 Test Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Hiển thị tên model
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Model: $_selectedModel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            Divider(),

            // Model Loading
            _buildMetricRow(
              icon: Icons.download,
              color: Colors.blue,
              label: 'Model Loading Time',
              value: '${_modelLoadingTimeMs}ms',
              subtitle: 'Size: ${_modelBytes!.length ~/ 1024}KB',
            ),

            SizedBox(height: 12),

            // Inference Performance
            _buildMetricRow(
              icon: Icons.speed,
              color: Colors.green,
              label: 'Average Inference Time',
              value: '${_inferenceMetrics!.inferenceAvgMs}ms',
              subtitle: 'FPS: ${_inferenceMetrics!.fps.toStringAsFixed(1)}',
            ),

            SizedBox(height: 8),

            _buildMetricRow(
              icon: Icons.timeline,
              color: Colors.orange,
              label: 'Performance Range',
              value: '${_inferenceMetrics!.inferenceMinMs}-${_inferenceMetrics!.inferenceMaxMs}ms',
              subtitle: 'Std Dev: ±${_inferenceMetrics!.inferenceStdDevMs}ms',
            ),

            SizedBox(height: 8),

            _buildMetricRow(
              icon: Icons.pie_chart,
              color: Colors.purple,
              label: 'Processing Breakdown',
              value: 'Pre: ${_inferenceMetrics!.preprocessAvgMs}ms | Post: ${_inferenceMetrics!.postprocessAvgMs}ms',
              subtitle: 'Core Inference: ${_inferenceMetrics!.inferenceAvgMs - _inferenceMetrics!.preprocessAvgMs - _inferenceMetrics!.postprocessAvgMs}ms',
            ),

            SizedBox(height: 16),

            // Performance Rating
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getRatingColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getRatingColor().withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRatingIcon(),
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getRatingText().toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // Ghi chú
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '* Results based on 10 stable measurements after warmup',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor() {
    final avgMs = _inferenceMetrics?.inferenceAvgMs ?? 0;
    if (avgMs < 100) return Colors.green;
    if (avgMs < 200) return Colors.blue;
    if (avgMs < 300) return Colors.orange;
    return Colors.red;
  }

  IconData _getRatingIcon() {
    final avgMs = _inferenceMetrics?.inferenceAvgMs ?? 0;
    if (avgMs < 100) return Icons.star;
    if (avgMs < 200) return Icons.thumb_up;
    if (avgMs < 300) return Icons.warning;
    return Icons.error;
  }

  String _getRatingText() {
    final avgMs = _inferenceMetrics?.inferenceAvgMs ?? 0;
    if (avgMs < 100) return 'Excellent';
    if (avgMs < 200) return 'Good';
    if (avgMs < 300) return 'Fair';
    return 'Poor';
  }

  Widget _buildStatusCard() {
    return Card(
      color: _isTesting ? Colors.blue[50] : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_isTesting)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.blue[100],
                color: Colors.blue,
              ),
            SizedBox(height: _isTesting ? 12 : 0),
            Row(
              children: [
                Icon(
                  _isTesting ? Icons.hourglass_bottom : Icons.info,
                  color: _isTesting ? Colors.blue : Colors.grey,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: _isTesting ? Colors.blue[800] : Colors.grey[700],
                      fontWeight: _isTesting ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Performance Benchmark',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Device Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Device',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          FutureBuilder<String>(
                            future: getDeviceInfoString(),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Loading device info...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Model Selection Card
            _buildModelSelectionCard(),

            SizedBox(height: 20),

            // Status Card
            _buildStatusCard(),

            SizedBox(height: 20),

            // Start Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isTesting || _modelBytes == null)
                    ? null
                    : _runPerformanceTest,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isTesting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Testing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Start Performance Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Results Card
            if (_inferenceMetrics != null) ...[
              _buildResultsCard(),
              SizedBox(height: 16),
            ],

            // Legend/Explanation
            Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.grey, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Performance Ratings',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRatingIndicator('Excellent', Colors.green),
                        SizedBox(width: 8),
                        _buildRatingIndicator('Good', Colors.blue),
                        SizedBox(width: 8),
                        _buildRatingIndicator('Fair', Colors.orange),
                        SizedBox(width: 8),
                        _buildRatingIndicator('Poor', Colors.red),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Excellent: <100ms (Real-time ready)\n'
                          '• Good: 100-200ms (Acceptable for most apps)\n'
                          '• Fair: 200-300ms (May need optimization)\n'
                          '• Poor: >300ms (Needs significant optimization)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingIndicator(String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}