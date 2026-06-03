import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';


class CropScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final BloomTheme t;
  const CropScreen({super.key, required this.imageFile, required this.t});

  @override
  ConsumerState<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends ConsumerState<CropScreen> {
  Uint8List? _imageData;
  final _controller = CropController();
  bool _isCropping = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      if (mounted) setState(() => _imageData = bytes);
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
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
          tooltip: 'Tutup',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: _hasError
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(child: Icon(Icons.broken_image_rounded, color: t.mutedText, size: S.scale(context, 48))),
                    SizedBox(height: S.scale(context, 16)),
                    Text(
                      'Gagal memuat gambar',
                      style: TextStyle(color: t.mutedText, fontSize: S.font(context, 14)),
                    ),
                    SizedBox(height: S.scale(context, 16)),
                    Game3DButton(
                      label: 'Kembali',
                      color: t.primary,
                      shadowColor: t.textPrimary,
                      textColor: t.primaryContent,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              )
            : _imageData == null
                ? Center(child: CircularProgressIndicator(color: t.primary))
                : Column(
                    children: [
                      Expanded(
                        child: Crop(
                          image: _imageData!,
                          controller: _controller,
                          withCircleUi: true,
                          baseColor: t.bgPrimary,
                          onCropped: (cropped) async {
                            final scaffold = ScaffoldMessenger.of(context);
                            try {
                              final dir = Directory.systemTemp;
                              final file = File(
                                '${dir.path}/avatar_cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
                              );
                              await file.writeAsBytes(cropped);
                              if (context.mounted) Navigator.pop(context, file);
                            } catch (e) {
                              if (mounted) setState(() => _isCropping = false);
                              scaffold.showSnackBar(
                                SnackBar(content: Text('Gagal menyimpan gambar: $e')),
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(S.scale(context, 24), S.scale(context, 16), S.scale(context, 24), S.scale(context, 24)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Game3DButton(
                                label: 'Ulangi',
                                color: t.bgSurface,
                                shadowColor: t.textPrimary,
                                textColor: t.textPrimary,
                                horizontalPadding: S.scale(context, 16),
                                verticalPadding: S.scale(context, 13),
                                onTap: () => Navigator.pop(context),
                              ),
                            ),
                            SizedBox(width: S.scale(context, 16)),
                            Expanded(
                              child: Game3DButton(
                                label: 'Simpan',
                                color: t.primary,
                                shadowColor: t.textPrimary,
                                textColor: t.primaryContent,
                                horizontalPadding: S.scale(context, 16),
                                verticalPadding: S.scale(context, 13),
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
