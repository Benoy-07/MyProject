// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class QrVerificationScreen extends StatefulWidget {
//   @override
//   _QrVerificationScreenState createState() => _QrVerificationScreenState();
// }

// class _QrVerificationScreenState extends State<QrVerificationScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   Barcode? result;
//   QRViewController? controller;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('QR Verification')),
//       body: Column(
//         children: [
//           Expanded(
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: (c) {
//                 controller = c;
//                 c.scannedDataStream.listen((scanData) {
//                   setState(() => result = scanData);
//                   // verify scanned code with backend if needed
//                 });
//               },
//             ),
//           ),
//           if (result != null)
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Text('Scanned: ${result!.code}'),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
