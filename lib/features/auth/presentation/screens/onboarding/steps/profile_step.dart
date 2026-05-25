import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../../../features/profile/presentation/widgets/crop_screen.dart';
import '../../../../../../shared/themes/theme_provider.dart';

class ProfileStep extends ConsumerWidget {
  final File? avatarFile;
  final ValueChanged<File> onAvatarPicked;

  const ProfileStep({
    super.key,
    required this.avatarFile,
    required this.onAvatarPicked,
  });

  Future<void> _pickImage(BuildContext context, BloomTheme t) async {
    final result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.image,
      ),
    );
    final asset = result?.firstOrNull;
    if (asset == null) return;
    final file = await asset.file;
    if (file == null || !context.mounted) return;

    final cropped = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => CropScreen(imageFile: file, t: t),
      ),
    );
    if (cropped != null && context.mounted) {
      onAvatarPicked(cropped);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(Icons.face_rounded, size: 56, color: t.primary),
          const SizedBox(height: 16),
          Text('Pilih Foto Profil',
              style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.w900, color: t.textPrimary)),
          const SizedBox(height: 8),
          Text('Tambahkan avatar biar profil kamu makin kece',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: t.mutedText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => _pickImage(context, ref.read(currentThemeProvider)),
            child: Stack(
              children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.bgSurface2,
                    border: Border.all(color: t.primary, width: 3),
                    image: avatarFile != null
                        ? DecorationImage(
                            image: FileImage(avatarFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: avatarFile == null
                      ? Icon(Icons.person_rounded, size: 48, color: t.mutedText)
                      : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: t.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.bgPrimary, width: 3),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        color: t.primaryContent, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Klik avatar untuk upload foto',
              style: GoogleFonts.nunito(
                  fontSize: 12, color: t.mutedText, fontWeight: FontWeight.w500)),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
