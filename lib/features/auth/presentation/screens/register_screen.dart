import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/services/sound_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConf = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  double r(double px) {
    final w = MediaQuery.of(context).size.width;
    return px * (w / 390).clamp(0.8, 1.3);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (ok && mounted) {
      context.go('/onboarding');
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon, BloomTheme t) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: t.mutedText, fontSize: r(13)),
      prefixIcon: Icon(icon, color: t.textPrimary, size: r(20)),
      filled: true,
      fillColor: t.bgSurface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r(10)),
        borderSide: BorderSide(color: t.textPrimary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r(10)),
        borderSide: BorderSide(color: t.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r(10)),
        borderSide: BorderSide(color: t.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: r(16), vertical: r(14)),
    );
  }

  InputDecoration _passwordInputDecoration(BloomTheme t) {
    return _inputDecoration('••••••••', Icons.lock_outline, t);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final t = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r(24)),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Badge + logo
                    Center(
                      child:
                          Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: r(12),
                                      vertical: r(3),
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(r(20)),
                                      border: Border.all(
                                        color: t.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Welcome to Bloom',
                                      style: GoogleFonts.nunito(
                                          fontSize: r(12),
                                        fontWeight: FontWeight.w600,
                                        color: t.textPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: r(8)),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: r(44),
                                        height: r(44),
                                        decoration: BoxDecoration(
                                          color: t.primary,
                                          borderRadius: BorderRadius.circular(
                                            r(12),
                                          ),
                                          border: Border.all(
                                            color: t.textPrimary,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: t.textPrimary,
                                              offset: Offset(r(2), r(2)),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '🌸',
                                            style: TextStyle(fontSize: r(22)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: r(10)),
                                      Text(
                                        'Bloom',
                                        style: GoogleFonts.nunito(
                                          fontSize: r(28),
                                          fontWeight: FontWeight.w900,
                                          color: t.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(begin: const Offset(.8, .8)),
                    ),

                    SizedBox(height: r(32)),

                    // Form card — Neo Brutalism
                    Container(
                      padding: EdgeInsets.all(r(22)),
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(r(10)),
                        border: Border.all(color: t.textPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: Offset(r(3), r(3)),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField(
                              'Nama Lengkap',
                              _nameCtrl,
                              t,
                              icon: Icons.person_outline_rounded,
                              hint: 'Muhammad Athif',
                              validator: (v) => (v == null || v.length < 3)
                                  ? 'Min. 3 karakter'
                                  : null,
                            ),
                            SizedBox(height: r(14)),
                            _buildField(
                              'Email',
                              _emailCtrl,
                              t,
                              icon: Icons.email_outlined,
                              hint: 'nama@email.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || !v.contains('@'))
                                  ? 'Email tidak valid'
                                  : null,
                            ),
                            SizedBox(height: r(14)),
                            _buildPasswordField(
                              'Password',
                              _passCtrl,
                              t,
                              _obscure,
                              () => setState(() => _obscure = !_obscure),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Min. 6 karakter'
                                  : null,
                            ),
                            SizedBox(height: r(14)),
                            _buildPasswordField(
                              'Konfirmasi Password',
                              _confCtrl,
                              t,
                              _obscureConf,
                              () =>
                                  setState(() => _obscureConf = !_obscureConf),
                              validator: (v) => v != _passCtrl.text
                                  ? 'Password tidak cocok'
                                  : null,
                            ),

                            if (auth.error != null) ...[
                              SizedBox(height: r(12)),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(r(12)),
                                decoration: BoxDecoration(
                                  color: t.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(r(10)),
                                  border: Border.all(color: t.error, width: 2),
                                ),
                                child: Text(
                                  auth.error!,
                                  style: GoogleFonts.nunito(
                                    color: t.error,
                                    fontSize: r(12),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ).animate().fadeIn().shakeX(),
                            ],

                            SizedBox(height: r(20)),

                            SizedBox(
                              width: double.infinity,
                              child: Game3DButton(
                                label: 'Daftar & Mulai Belajar',
                                color: t.primary,
                                shadowColor: t.textPrimary,
                                textColor: t.primaryContent,
                                horizontalPadding: r(16),
                                isLoading: auth.isLoading,
                                onTap: auth.isLoading ? null : _submit,
                                child: auth.isLoading
                                    ? null
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Daftar & Mulai Belajar',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w800,
                                              fontSize: r(14),
                                              color: t.primaryContent,
                                            ),
                                          ),
                                          SizedBox(width: r(8)),
                                          Icon(
                                            Icons.rocket_launch_rounded,
                                            color: t.primaryContent,
                                            size: r(16),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.1),
                    SizedBox(height: r(12)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontSize: r(14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(soundProvider).playClick();
                            context.pop();
                          },
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.nunito(
                              color: t.primary,
                              fontSize: r(14),
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                              decorationColor: t.primary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 460.ms),
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

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    BloomTheme t, {
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: r(13),
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
          ),
        ),
        SizedBox(height: r(8)),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: GoogleFonts.nunito(color: t.textPrimary),
          decoration: _inputDecoration(hint, icon, t),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
    BloomTheme t,
    bool obscure,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: r(13),
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
          ),
        ),
        SizedBox(height: r(8)),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          style: GoogleFonts.nunito(color: t.textPrimary),
          decoration: _passwordInputDecoration(t).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: t.mutedText,
                size: r(20),
              ),
              onPressed: () {
                ref.read(soundProvider).playClick();
                toggle();
              },
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
