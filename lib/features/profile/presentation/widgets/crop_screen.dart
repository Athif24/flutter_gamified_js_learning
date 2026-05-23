import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
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
    final t = widget.t;
    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: t.textPrimary),
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
                baseColor: t.bgPrimary,
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
                    child: Bounceable(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: t.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: t.textPrimary, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Ulangi',
                          style: GoogleFonts.nunito(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Bounceable(
                      onTap: () => _controller.crop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: t.textPrimary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Simpan',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
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
