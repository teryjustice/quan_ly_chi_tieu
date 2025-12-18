import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleQRCode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final qrCode = barcodes.first.rawValue;
    if (qrCode == null || qrCode.isEmpty) return;

    _isProcessing = true;

    // Phát âm thanh/xúc cảm khi quét thành công
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quét thành công: $qrCode'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Quay lại màn hình trước và truyền dữ liệu QR
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop(qrCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Mã QR'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: controller,
            onDetect: _handleQRCode,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi camera: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => controller.start(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Overlay với khung quét
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Góc trên trái
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.green, width: 3),
                          left: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // Góc trên phải
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.green, width: 3),
                          right: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // Góc dưới trái
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.green, width: 3),
                          left: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // Góc dưới phải
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.green, width: 3),
                          right: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Phần dưới màn hình với hướng dẫn
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Hãy đặt mã QR vào khung để quét',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Nút Bật/Tắt Flash
                      FloatingActionButton.small(
                        onPressed: () {
                          controller.toggleTorch();
                        },
                        backgroundColor: Colors.white10,
                        child: const Icon(Icons.flashlight_on, color: Colors.white),
                      ),

                      // Nút Chuyển Camera
                      FloatingActionButton.small(
                        onPressed: () {
                          controller.switchCamera();
                        },
                        backgroundColor: Colors.white10,
                        child: const Icon(Icons.flip_camera_android, color: Colors.white),
                      ),

                      // Nút Đóng
                      FloatingActionButton.small(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
