import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/booking_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  String _lastScannedCode = '';

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcodeScan(BarcodeCapture barcodes) {
    if (!_isScanning) return;

    final barcode = barcodes.barcodes.first;
    if (barcode.rawValue == null) return;
    
    final code = barcode.rawValue!;
    if (code == _lastScannedCode) return;

    setState(() {
      _lastScannedCode = code;
      _isScanning = false;
    });

    _processScannedCode(code);
  }

  Future<void> _processScannedCode(String code) async {
    try {
      // Parse QR code data
      final parts = code.split(':');
      if (parts.length != 4 || parts[0] != 'HALL_DINING') {
        _showErrorDialog('Invalid QR Code');
        return;
      }

      final bookingId = parts[1];
      final userId = parts[2];
      final timestamp = int.tryParse(parts[3]);

      if (timestamp == null) {
        _showErrorDialog('Invalid QR Code');
        return;
      }

      // Verify booking
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final isValid = await bookingProvider.verifyBooking(
        bookingId: bookingId,
        userId: userId,
      );

      if (isValid && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorDialog('Invalid or expired booking');
      }
    } catch (e) {
      _showErrorDialog('Error processing QR code: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Booking Verified'),
          ],
        ),
        content: const Text('Meal successfully verified and served.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Verification Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _lastScannedCode = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcodeScan,
          ),

          // Scanner Overlay
          _buildScannerOverlay(),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Scan Meal QR Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position the QR code within the frame',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return CustomPaint(
      painter: QrScannerOverlay(
        borderColor: Colors.green,
        borderWidth: 4.0,
        overlayColor: Colors.black54,
        borderRadius: 12.0,
        cutOutSize: 250.0,
      ),
    );
  }
}

class QrScannerOverlay extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double cutOutSize;

  QrScannerOverlay({
    required this.borderColor,
    required this.borderWidth,
    required this.overlayColor,
    required this.borderRadius,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final path = Path()..addRect(Rect.largest);
    final cutOutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: cutOutSize,
          height: cutOutSize,
        ),
        Radius.circular(borderRadius),
      ));

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    path.addPath(cutOutPath, Offset.zero);
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
    canvas.drawPath(cutOutPath, borderPaint);

    // Draw corner lines
    final cornerLength = 20.0;
    final cornerWidth = 4.0;
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final halfSize = cutOutSize / 2;

    // Top left corner
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy - halfSize + cornerLength),
      Offset(center.dx - halfSize, center.dy - halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy - halfSize),
      Offset(center.dx - halfSize + cornerLength, center.dy - halfSize),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(center.dx + halfSize - cornerLength, center.dy - halfSize),
      Offset(center.dx + halfSize, center.dy - halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + halfSize, center.dy - halfSize),
      Offset(center.dx + halfSize, center.dy - halfSize + cornerLength),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy + halfSize - cornerLength),
      Offset(center.dx - halfSize, center.dy + halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy + halfSize),
      Offset(center.dx - halfSize + cornerLength, center.dy + halfSize),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(center.dx + halfSize - cornerLength, center.dy + halfSize),
      Offset(center.dx + halfSize, center.dy + halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + halfSize, center.dy + halfSize),
      Offset(center.dx + halfSize, center.dy + halfSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}