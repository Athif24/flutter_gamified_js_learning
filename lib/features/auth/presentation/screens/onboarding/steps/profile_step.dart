import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import '../../../../../../features/profile/presentation/widgets/crop_screen.dart';

class ProfileStep extends ConsumerWidget {
  final File? avatarFile;
  final ValueChanged<File?> onAvatarPicked;
  const ProfileStep({super.key, required this.avatarFile, required this.onAvatarPicked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: S.scale(context, 24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ExcludeSemantics(child: Icon(Icons.face_rounded, size: S.scale(context, 56), color: t.primary)),
          SizedBox(height: S.scale(context, 16)),
          Text(
            'Pilih Foto Profil',
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 22),
              fontWeight: FontWeight.w900,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: S.scale(context, 8)),
          Text(
            'Tambahkan foto agar teman-temanmu bisa mengenalimu',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 13),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: S.scale(context, 24)),
          GestureDetector(
            onTap: () {
              _pickAvatar(context, ref, t);
            },
            child: Semantics(
              button: true,
              label: 'Pilih avatar',
              child: Stack(
                children: [
                  Container(
                    width: S.scale(context, 110),
                    height: S.scale(context, 110),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.bgSurface2,
                      border: Border.all(color: t.textPrimary, width: S.scale(context, 3)),
                      boxShadow: [
                        BoxShadow(
                          color: t.textPrimary,
                          offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: avatarFile != null
                        ? ClipOval(
                            child: Image.file(
                              avatarFile!,
                              fit: BoxFit.cover,
                              width: S.scale(context, 110),
                              height: S.scale(context, 110),
                            ),
                          )
                        : Icon(Icons.person_rounded, size: S.scale(context, 48), color: t.mutedText),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: S.scale(context, 36),
                      height: S.scale(context, 36),
                      decoration: BoxDecoration(
                        color: t.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                      ),
                      child: Icon(Icons.camera_alt_rounded, size: S.scale(context, 18), color: t.primaryContent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: S.scale(context, 8)),
          Text(
            avatarFile != null ? 'Tap untuk ganti foto' : 'Tap untuk upload foto',
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 12),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref, BloomTheme t) async {
    try {
      final result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          textDelegate: const EnglishAssetPickerTextDelegate(),
        ),
      );
      final asset = result?.firstOrNull;
      if (asset == null) return;
      final file = await asset.file;
      if (file == null || !context.mounted) return;
      final tempDir = Directory.systemTemp;
      final safeFile = File(
        '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await safeFile.writeAsBytes(await file.readAsBytes());
      if (!context.mounted) return;
      final cropped = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (_) => CropScreen(imageFile: safeFile, t: t),
        ),
      );
      if (cropped != null) onAvatarPicked(cropped);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat gambar: $e')),
        );
      }
    }
  }
}
