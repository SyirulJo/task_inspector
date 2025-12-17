import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController? controller;

  @override
  void initState() {
    super.initState();
    // Only initialize scanner on mobile platforms
    if (!kIsWeb) {
      controller = MobileScannerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: kIsWeb ? _buildWebView(context) : _buildMobileView(context),
    );
  }

  Widget _buildWebView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 120,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'QR Scanner Simulation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Camera access is not available on web.\nUse the buttons below to simulate scanning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildSimulationButton(context, 'Generator A', 'asset_1_qr_code'),
            const SizedBox(height: 12),
            _buildSimulationButton(context, 'HVAC Unit 3', 'asset_2_qr_code'),
            const SizedBox(height: 12),
            _buildSimulationButton(context, 'Fire Pump', 'asset_3_qr_code'),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationButton(BuildContext context, String assetName, String qrCode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.pop(qrCode),
        icon: const Icon(Icons.qr_code_2),
        label: Text('Scan $assetName'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: MobileScanner(
            controller: controller!,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  controller!.stop();
                  context.pop(barcode.rawValue);
                  break;
                }
              }
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Align QR code within the frame'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop('asset_1_qr_code'),
                  child: const Text('(Dev) Simulate Scan'),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
