import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../providers/auth_provider.dart';

import '../../../../core/utils/responsive_utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formCardKey = GlobalKey();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  double _prevBottom = 0;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    if (bottom > 0 && _prevBottom == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_formCardKey.currentContext != null) {
          Scrollable.ensureVisible(
            _formCardKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
    _prevBottom = bottom;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      invalidateGamificationProviders(ref);
      ref.invalidate(coursesProvider);
      ref.invalidate(courseDetailProvider);
      ref.invalidate(myQuizResultProvider);
      ref.read(navIndexProvider.notifier).state = 0;
      context.go('/home');
    } else if (!ok && mounted) {
      final auth = ref.read(authProvider);
      if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              auth.error!,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: ref.read(currentThemeProvider).error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon, BloomTheme t) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: t.mutedText, fontSize: S.font(context, 13)),
      prefixIcon: ExcludeSemantics(child: Icon(icon, color: t.textPrimary, size: S.scale(context, 20))),
      filled: true,
      fillColor: t.bgSurface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.scale(context, 10)),
        borderSide: BorderSide(color: t.textPrimary, width: S.scale(context, 2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.scale(context, 10)),
        borderSide: BorderSide(color: t.border, width: S.scale(context, 2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.scale(context, 10)),
        borderSide: BorderSide(color: t.primary, width: S.scale(context, 2)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: S.scale(context, 16), vertical: S.scale(context, 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final t = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: S.scale(context, 24)),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Column(
                          children: [
                            Container(
                              width: S.scale(context, 72),
                              height: S.scale(context, 72),
                              decoration: BoxDecoration(
                                color: t.primary,
                                shape: BoxShape.circle,
                                  border: Border.all(
                                    color: t.textPrimary,
                                    width: S.scale(context, 2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: t.textPrimary,
                                      offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(t.primaryContent, BlendMode.srcIn),
                                  child: Image.asset(
                                    'assets/logo/logo_app.png',
                                    width: S.scale(context, 36),
                                    height: S.scale(context, 36),
                                  ),
                                ),
                              ),
                            SizedBox(height: S.scale(context, 10)),
                              Text(
                                'Bloom',
                                style: GoogleFonts.nunito(
                                  fontSize: S.font(context, 28),
                                fontWeight: FontWeight.w900,
                                color: t.textPrimary,
                              ),
                            ),
                            Text(
                              'JavaScript Learning',
                              style: GoogleFonts.nunito(
                                fontSize: S.font(context, 13),
                                color: t.mutedText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(.8, .8)),

                    SizedBox(height: S.scale(context, 20)),

                    Text(
                      'Selamat Datang!',
                      style: GoogleFonts.nunito(
                        fontSize: S.font(context, 22),
                        fontWeight: FontWeight.w800,
                        color: t.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    SizedBox(height: S.scale(context, 6)),
                    Text(
                      'Masuk dan lanjutkan belajar JavaScript-mu',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: S.font(context, 13),
                        color: t.mutedText,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    SizedBox(height: S.scale(context, 24)),

                    // Form card — Neo Brutalism
                    Container(
                      key: _formCardKey,
                      padding: EdgeInsets.all(S.scale(context, 22)),
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(S.scale(context, 10)),
                        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Email', t),
                            SizedBox(height: S.scale(context, 8)),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.nunito(color: t.textPrimary),
                              decoration: _inputDecoration(
                                'Masukkan email',
                                Icons.email_outlined,
                                t,
                              ),
                              validator: (v) => (v == null || !v.contains('@'))
                                  ? 'Email tidak valid'
                                  : null,
                            ).animate().fadeIn(delay: 300.ms),

                            SizedBox(height: S.scale(context, 14)),
                            _Label('Password', t),
                            SizedBox(height: S.scale(context, 8)),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              style: GoogleFonts.nunito(color: t.textPrimary),
                              decoration:
                                  _inputDecoration(
                                    '••••••••',
                                    Icons.lock_outline,
                                    t,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: t.mutedText,
                                        size: S.scale(context, 20),
                                      ),
                                      onPressed: () {
                                        setState(() => _obscure = !_obscure);
                                      },
                                    ),
                                  ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Min. 6 karakter'
                                  : null,
                            ).animate().fadeIn(delay: 350.ms),

                            SizedBox(height: S.scale(context, 20)),

                            SizedBox(
                              width: double.infinity,
                              child: Game3DButton(
                                label: 'Masuk',
                                color: t.primary,
                                shadowColor: t.textPrimary,
                                textColor: t.primaryContent,
                                horizontalPadding: S.scale(context, 16),
                                isLoading: auth.isLoading,
                                onTap: auth.isLoading ? null : _submit,
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.1),
                    SizedBox(height: S.scale(context, 12)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontSize: S.font(context, 14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push('/register');
                          },
                          child: Text(
                            'Daftar Sekarang',
                            style: GoogleFonts.nunito(
                              color: t.primary,
                              fontSize: S.font(context, 14),
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                              decorationColor: t.primary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final BloomTheme t;
  const _Label(this.text, this.t);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.nunito(
      fontSize: S.font(context, 13),
      fontWeight: FontWeight.w700,
      color: t.textPrimary,
    ));
  }
}
