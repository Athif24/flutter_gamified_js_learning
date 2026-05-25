import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../providers/auth_provider.dart';
import 'steps/welcome_step.dart';
import 'steps/profile_step.dart';
import 'steps/theme_step.dart';
import 'steps/sound_step.dart';
import 'steps/notification_step.dart';
import 'steps/position_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;
  File? _avatarFile;

  List<Widget> get _steps => [
    WelcomeStep(),
    ProfileStep(avatarFile: _avatarFile, onAvatarPicked: (f) => setState(() => _avatarFile = f)),
    ThemeStep(),
    SoundStep(),
    NotificationStep(),
    PositionStep(),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  bool get _isLast => _current == _steps.length - 1;
  bool get _isFirst => _current == 0;

  void _next() {
    if (_isLast) return;
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prev() {
    if (_isFirst) return;
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

Future<void> _finish() async {
  if (_avatarFile != null && mounted) {
    try {
      final url = await CloudinaryService.uploadImage(_avatarFile!.path);
      if (mounted) {
        await ref.read(authProvider.notifier).updateProfile(avatar: url);
      }
    } catch (_) {
      // Avatar upload gagal — tetap lanjut ke onboarding
    }
  }
  if (mounted) {
    await ref.read(authProvider.notifier).completeOnboarding();
    if (mounted) context.go('/home');
  }
}

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final progress = (_current + 1) / _steps.length;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
Padding(
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
  child: Column(
    children: [
      Row(
        children: [
          _isFirst
              ? const SizedBox(width: 36, height: 36)
              : GestureDetector(
                  onTap: _prev,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 36, height: 36,
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: t.textPrimary, size: 14),
                  ),
                ),
          const Spacer(),
          if (!_isLast)
            GestureDetector(
              onTap: _next,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 36, height: 36,
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: t.textPrimary, size: 14),
              ),
            )
          else
            const SizedBox(width: 36),
        ],
      ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: t.bgSurface2,
                      valueColor: AlwaysStoppedAnimation(t.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (i) {
                      final active = i <= _current;
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? t.primary : t.border,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _current = i),
                physics: const ClampingScrollPhysics(),
                children: _steps,
              ),
            ),
            if (_isLast)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: Game3DButton(
                    label: 'Mulai Belajar!',
                    color: t.primary,
                    shadowColor: t.textPrimary,
                    textColor: t.primaryContent,
                    horizontalPadding: 16,
                    onTap: _finish,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: Game3DButton(
                    label: 'Lanjut',
                    color: t.primary,
                    shadowColor: t.textPrimary,
                    textColor: t.primaryContent,
                    horizontalPadding: 16,
                    onTap: _next,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
