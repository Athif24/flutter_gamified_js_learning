import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../store/presentation/providers/store_provider.dart';
import '../../../store/presentation/providers/reward_pool_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../data/models/profile_model.dart';
import 'crop_screen.dart';

Future<void> showEditProfile(
  BuildContext context,
  WidgetRef ref,
  BloomTheme t,
  ProfileModel profile,
) {
  final nameController = TextEditingController(text: profile.name);
  final emailController = TextEditingController(text: profile.email);
  final formKey = GlobalKey<FormState>();
  final initials = profile.initials;
  bool isLoading = false;
  File? avatarFile;
  String? avatarUrl = profile.avatar;

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(S.scale(context, 20))),
        insetPadding: EdgeInsets.symmetric(horizontal: S.scale(context, 20), vertical: S.scale(context, 40)),
        content: Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(S.scale(context, 20)),
          decoration: BoxDecoration(
            color: t.bgSurface,
            border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
            borderRadius: BorderRadius.circular(S.scale(context, 20)),
            boxShadow: [
              BoxShadow(
                color: t.textPrimary,
                offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                blurRadius: 0,
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: S.font(context, 18),
                      ),
                    ),
                  ),
                  SizedBox(height: S.scale(context, 4)),
                  Center(
                    child: Text(
                      'Update foto, nama, dan email kamu di sini.',
                      style: GoogleFonts.nunito(
                        color: t.textSecondary,
                        fontSize: S.font(context, 12),
                      ),
                    ),
                  ),
                  SizedBox(height: S.scale(context, 16)),

                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: t.textPrimary,
                                  width: S.scale(context, 3),
                                ),
                              ),
                              child: CircleAvatar(
                                radius: S.scale(context, 48),
                                backgroundColor: t.bgSurface2,
                                backgroundImage: avatarFile != null
                                    ? FileImage(avatarFile!)
                                    : (avatarUrl != null
                                          ? NetworkImage(avatarUrl!)
                                          : null),
                                child: avatarFile == null && avatarUrl == null
                                    ? Text(
                                        initials,
                                        style: GoogleFonts.nunito(
                                          color: t.primary,
                                          fontSize: S.font(context, 36),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            if (avatarFile != null || avatarUrl != null)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: GestureDetector(
                                  onTap: () {
                                    ref.read(soundProvider).playClick();
                                    setState(() {
                                      avatarFile = null;
                                      avatarUrl = null;
                                    });
                                  },
                                  child: Container(
                                    width: S.scale(context, 28),
                                    height: S.scale(context, 28),
                                    decoration: BoxDecoration(
                                      color: t.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: t.textPrimary,
                                        width: S.scale(context, 2),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: t.bgPrimary,
                                        size: S.scale(context, 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: S.scale(context, 12)),
                        Bounceable(
                          onTap: () async {
                            ref.read(soundProvider).playClick();
                            final result = await AssetPicker.pickAssets(
                              ctx,
                              pickerConfig: const AssetPickerConfig(
                                maxAssets: 1,
                                requestType: RequestType.image,
                              ),
                            );
                            final asset = result?.firstOrNull;
                            if (asset != null) {
                              final file = await asset.file;
                              if (file != null && ctx.mounted) {
                                final cropped = await Navigator.of(ctx)
                                    .push<File>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CropScreen(imageFile: file, t: t),
                                      ),
                                    );
                                if (cropped != null) {
                                  setState(() => avatarFile = cropped);
                                }
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: S.scale(context, 12),
                              vertical: S.scale(context, 6),
                            ),
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(S.scale(context, 10)),
                              border: Border.all(
                                color: t.textPrimary,
                                width: S.scale(context, 2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: t.textPrimary,
                                  offset: Offset(S.scale(context, 2), S.scale(context, 2)),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.upload_rounded,
                                  size: S.scale(context, 14),
                                  color: t.textPrimary,
                                ),
                                SizedBox(width: S.scale(context, 6)),
                                Text(
                                  avatarFile != null || avatarUrl != null
                                      ? 'Ganti Foto Ah'
                                      : 'Upload Foto Kece',
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: S.font(context, 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: S.scale(context, 4)),
                        Text(
                          'Format JPG/PNG/GIF, max 5MB ya!',
                          style: GoogleFonts.nunito(
                            color: t.textHint,
                            fontSize: S.font(context, 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: S.scale(context, 16)),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nama',
                      style: GoogleFonts.nunito(
                        color: t.textSecondary,
                        fontSize: S.font(context, 12),
                        fontWeight: FontWeight.w700,
                        letterSpacing: S.scale(context, 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: S.scale(context, 6)),
                  TextFormField(
                    controller: nameController,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: S.font(context, 14),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.nunito(color: t.textHint),
                      filled: true,
                      fillColor: t.bgSurface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(S.scale(context, 12)),
                        borderSide: BorderSide(color: t.textPrimary, width: S.scale(context, 2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(S.scale(context, 12)),
                        borderSide: BorderSide(color: t.textPrimary, width: S.scale(context, 2)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: S.scale(context, 14),
                        vertical: S.scale(context, 10),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  SizedBox(height: S.scale(context, 16)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.nunito(
                        color: t.textSecondary,
                        fontSize: S.font(context, 12),
                        fontWeight: FontWeight.w700,
                        letterSpacing: S.scale(context, 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: S.scale(context, 6)),
                  TextFormField(
                    controller: emailController,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: S.font(context, 14),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.nunito(color: t.textHint),
                      filled: true,
                      fillColor: t.bgSurface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(S.scale(context, 12)),
                        borderSide: BorderSide(color: t.textPrimary, width: S.scale(context, 2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(S.scale(context, 12)),
                        borderSide: BorderSide(color: t.textPrimary, width: S.scale(context, 2)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: S.scale(context, 14),
                        vertical: S.scale(context, 10),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!v.contains('@')) return 'Email tidak valid';
                      return null;
                    },
                  ),
                  SizedBox(height: S.scale(context, 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Game3DButton(
                          label: 'Batal',
                          color: t.secondary,
                          shadowColor: t.textPrimary,
                          textColor: t.secondaryContent,
                          onTap: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      SizedBox(width: S.scale(context, 12)),
                      Expanded(
                        child: Game3DButton(
                          label: 'Simpan',
                          color: t.primary,
                          shadowColor: t.textPrimary,
                          textColor: t.primaryContent,
                          onTap: isLoading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setState(() => isLoading = true);
                                  try {
                                    String? uploadedUrl;
                                    if (avatarFile != null) {
                                      uploadedUrl =
                                          await CloudinaryService.uploadImage(
                                            avatarFile!.path,
                                          );
                                    }
                                    final updateData = <String, dynamic>{
                                      'name': nameController.text.trim(),
                                      'email': emailController.text.trim(),
                                    };
                                    if (avatarFile != null) {
                                      updateData['avatar'] = uploadedUrl!;
                                    } else if (avatarUrl == null &&
                                        profile.avatar != null) {
                                      updateData['avatar'] = '';
                                    }
                                    await ref
                                        .read(profileDsProvider)
                                        .updateProfile(updateData);
                                    ref.invalidate(profileProvider);
                                    await ref.read(authProvider.notifier).refreshMe();
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Profil berhasil diperbarui',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          backgroundColor: t.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              S.scale(context, 12),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceAll(
                                              'Exception: ',
                                              '',
                                            ),
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: t.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              S.scale(context, 12),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          isLoading: isLoading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showChangePassword(
  BuildContext context,
  WidgetRef ref,
  BloomTheme t,
) {
  final currentPwController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  return showDialog(
    context: context,
    builder: (ctx) {
      bool showPassword = false;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(S.scale(context, 20)),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: S.scale(context, 20),
              vertical: S.scale(context, 40),
            ),
            content: Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(S.scale(context, 20)),
              decoration: BoxDecoration(
                color: t.bgSurface,
                border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                borderRadius: BorderRadius.circular(S.scale(context, 20)),
                boxShadow: [
                  BoxShadow(
                    color: t.textPrimary,
                    offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: S.scale(context, 20),
                            color: t.textPrimary,
                          ),
                          SizedBox(width: S.scale(context, 8)),
                          Expanded(
                            child: Text(
                              'Ubah Password',
                              style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: S.font(context, 18),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(soundProvider).playClick();
                              Navigator.of(ctx).pop();
                            },
                            child: Semantics(
                              label: 'Tutup dialog',
                              child: Container(
                                width: S.scale(context, 28),
                                height: S.scale(context, 28),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: t.textPrimary.withValues(alpha: 0.3),
                                    width: S.scale(context, 2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: S.scale(context, 16),
                                  color: t.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: S.scale(context, 4)),
                      Text(
                        'Pakai password yang kuat dan jangan bagikan ke siapa pun.',
                        style: GoogleFonts.nunito(
                          color: t.textSecondary,
                          fontSize: S.font(context, 12),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 16)),
                      TextFormField(
                        controller: currentPwController,
                        obscureText: !showPassword,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: S.font(context, 14),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password Sekarang',
                          labelStyle: GoogleFonts.nunito(
                            color: t.textSecondary,
                          ),
                          filled: true,
                          fillColor: t.bgSurface2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(S.scale(context, 12)),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: S.scale(context, 2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(S.scale(context, 12)),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: S.scale(context, 2),
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Masukkan password lama'
                            : null,
                      ),
                      SizedBox(height: S.scale(context, 12)),
                      TextFormField(
                        controller: newPwController,
                        obscureText: !showPassword,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: S.font(context, 14),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          labelStyle: GoogleFonts.nunito(
                            color: t.textSecondary,
                          ),
                          filled: true,
                          fillColor: t.bgSurface2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(S.scale(context, 12)),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: S.scale(context, 2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(S.scale(context, 12)),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: S.scale(context, 2),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Masukkan password baru';
                          }
                          if (v.length < 6) return 'Minimal 6 karakter';
                          return null;
                        },
                      ),
                      SizedBox(height: S.scale(context, 12)),
                      TextFormField(
                        controller: confirmPwController,
                        obscureText: !showPassword,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: S.font(context, 14),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          labelStyle: GoogleFonts.nunito(
                            color: t.textSecondary,
                          ),
                          filled: true,
                          fillColor: t.bgSurface2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(S.scale(context, 12)),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: S.scale(context, 2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(S.scale(context, 12)),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: S.scale(context, 2),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v != newPwController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: S.scale(context, 12)),
                      CheckboxListTile(
                        title: Text(
                          'Tampilkan Password',
                          style: GoogleFonts.nunito(
                            color: t.textPrimary,
                            fontSize: S.font(context, 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: showPassword,
                        onChanged: (value) =>
                            setState(() => showPassword = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(S.scale(context, 4)),
                        ),
                        side: BorderSide(color: t.textPrimary, width: S.scale(context, 2)),
                        activeColor: t.primary,
                        checkColor: t.primaryContent,
                        visualDensity: VisualDensity.compact,
                      ),
                      SizedBox(height: S.scale(context, 8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Game3DButton(
                              label: 'Batal',
                              color: t.secondary,
                              shadowColor: t.textPrimary,
                              textColor: t.secondaryContent,
                              onTap: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                          SizedBox(width: S.scale(context, 12)),
                          Expanded(
                            child: Game3DButton(
                              label: 'Simpan',
                              color: t.primary,
                              shadowColor: t.textPrimary,
                              textColor: t.primaryContent,
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      setState(() => isLoading = true);
                                      try {
                                        final error = await ref
                                            .read(authProvider.notifier)
                                            .changePassword(
                                              currentPwController.text,
                                              newPwController.text,
                                            );
                                        if (error != null) {
                                          setState(() => isLoading = false);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  error,
                                                  style: GoogleFonts.nunito(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                backgroundColor: t.error,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(S.scale(context, 12)),
                                                ),
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                        if (ctx.mounted) {
                                          Navigator.of(ctx).pop();
                                        }
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Password berhasil diubah!',
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              backgroundColor: t.success,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(S.scale(context, 12)),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (_) {
                                        setState(() => isLoading = false);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Terjadi kesalahan. Silakan coba lagi.',
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              backgroundColor: t.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(S.scale(context, 12)),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showLogoutConfirm(
  BuildContext context,
  WidgetRef ref,
  BloomTheme t,
) {
  bool isLoading = false;

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(S.scale(context, 20))),
        insetPadding: EdgeInsets.symmetric(horizontal: S.scale(context, 20), vertical: S.scale(context, 40)),
        content: Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(S.scale(context, 20)),
          decoration: BoxDecoration(
            color: t.bgSurface,
            border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
            borderRadius: BorderRadius.circular(S.scale(context, 20)),
            boxShadow: [
              BoxShadow(
                color: t.textPrimary,
                offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: S.scale(context, 8)),
              Icon(Icons.logout_rounded, size: S.scale(context, 48), color: t.error),
              SizedBox(height: S.scale(context, 16)),
              Text(
                'Keluar',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: S.font(context, 18),
                ),
              ),
              SizedBox(height: S.scale(context, 8)),
              Text(
                'Apakah kamu yakin ingin keluar?',
                style: GoogleFonts.nunito(color: t.textSecondary, fontSize: S.font(context, 14)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: S.scale(context, 24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Game3DButton(
                      label: 'Batal',
                      color: t.secondary,
                      shadowColor: t.textPrimary,
                      textColor: t.secondaryContent,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  SizedBox(width: S.scale(context, 12)),
                  Expanded(
                    child: Game3DButton(
                      label: 'Keluar',
                      color: t.error,
                      shadowColor: t.textPrimary,
                      textColor: t.bgPrimary,
                      onTap: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              try {
                                await ref.read(authProvider.notifier).logout();
                              } catch (e) {
                                setState(() => isLoading = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text('Gagal keluar: $e')),
                                  );
                                }
                                return;
                              }

                              invalidateGamificationProviders(ref, skip: {'xpHistory'});
                              ref.invalidate(coursesProvider);
                              ref.invalidate(courseDetailProvider);
                              ref.invalidate(storeItemsProvider);
                              ref.invalidate(inventoryProvider);
                              ref.invalidate(rewardPoolsProvider);
                              ref.read(navIndexProvider.notifier).state = 0;

                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Logout Berhasil',
                                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(S.scale(context, 12)),
                                    ),
                                  ),
                                );
                              }
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (context.mounted) context.go('/login');
                            },
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
