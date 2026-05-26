import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';

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
  bool _isCropping = false;

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
                    child: Game3DButton(
                      label: 'Ulangi',
                      color: t.bgSurface,
                      shadowColor: t.textPrimary,
                      textColor: t.textPrimary,
                      horizontalPadding: 16,
                      verticalPadding: 13,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Game3DButton(
                      label: 'Simpan',
                      color: t.primary,
                      shadowColor: t.textPrimary,
                      textColor: t.primaryContent,
                      horizontalPadding: 16,
                      verticalPadding: 13,
                      isLoading: _isCropping,
                      onTap: _isCropping ? null : () {
                        setState(() => _isCropping = true);
                        _controller.crop();
                      },
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
