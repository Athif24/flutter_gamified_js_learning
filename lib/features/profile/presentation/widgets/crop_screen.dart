import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';

class CropScreen extends StatefulWidget {
  final File imageFile;
  final BloomTheme t;
  const CropScreen({super.key, required this.imageFile, required this.t});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  late Uint8List _imageData;
  final _controller = CropController();

  @override
  void initState() {
    super.initState();
    _imageData = widget.imageFile.readAsBytesSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Crop(
                image: _imageData,
                controller: _controller,
                withCircleUi: true,
                baseColor: Colors.black,
                onCropped: (cropped) async {
                  final dir = Directory.systemTemp;
                  final file = File(
                    '${dir.path}/avatar_cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  );
                  await file.writeAsBytes(cropped);
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Ulangi',
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _controller.crop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
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
}
