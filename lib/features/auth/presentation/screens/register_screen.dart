import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confCtrl   = TextEditingController();
  bool _obscure     = true;
  bool _obscureConf = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier)
        .register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final t    = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: Stack(children: [
        Positioned(top: -40, left: -40, child: _Blob(120, t.info.withOpacity(0.12))),
        Positioned(top: 80, right: -20,  child: _Blob(80,  t.accent.withOpacity(0.15))),
        Positioned(bottom: 60, right: -30, child: _Blob(100, t.accent.withOpacity(0.1))),

        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 16),
            Row(children: [
              Bounceable(
                onTap: () => context.go('/login'),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: t.bgSurface2, shape: BoxShape.circle,
                      border: Border.all(color: t.border)),
                  child: Icon(Icons.arrow_back_ios_rounded,
                      color: t.textPrimary, size: 15),
                ),
              ),
              const SizedBox(width: 14),
              Text('Buat Akun Baru', style: Theme.of(context).textTheme.headlineMedium),
            ]).animate().fadeIn(),

            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Text('Mulai perjalanan belajar JavaScript-mu 🚀',
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: t.textSecondary,
                      fontWeight: FontWeight.w500)),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: t.bgSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: t.border),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24, offset: const Offset(0, 8),
                )],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field('Nama Lengkap', _nameCtrl, t,
                        icon: Icons.person_outline_rounded,
                        hint: 'Muhammad Athif',
                        validator: (v) => (v == null || v.length < 3) ? 'Min. 3 karakter' : null),
                    const SizedBox(height: 14),
                    _Field('Email', _emailCtrl, t,
                        icon: Icons.email_outlined,
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null),
                    const SizedBox(height: 14),
                    _PasswordField('Password', _passCtrl, t, _obscure,
                        () => setState(() => _obscure = !_obscure),
                        validator: (v) => (v == null || v.length < 6) ? 'Min. 6 karakter' : null),
                    const SizedBox(height: 14),
                    _PasswordField('Konfirmasi Password', _confCtrl, t, _obscureConf,
                        () => setState(() => _obscureConf = !_obscureConf),
                        validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null),

                    if (auth.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: t.error.withOpacity(0.3)),
                        ),
                        child: Text(auth.error!,
                            style: GoogleFonts.nunito(
                                color: t.error, fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ).animate().fadeIn().shakeX(),
                    ],

                    const SizedBox(height: 20),

                    Bounceable(
                      onTap: auth.isLoading ? () {} : _submit,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: t.accent,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [BoxShadow(
                            color: t.accent.withOpacity(0.4),
                            blurRadius: 14, offset: const Offset(0, 6),
                          )],
                        ),
                        child: Center(child: auth.isLoading
                            ? SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: t.accentText))
                            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text('Daftar & Mulai Belajar',
                                    style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14, color: t.accentText)),
                                const SizedBox(width: 8),
                                Icon(Icons.rocket_launch_rounded,
                                    color: t.accentText, size: 16),
                              ])),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Sudah punya akun? ',
                  style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13)),
              Bounceable(
                onTap: () => context.go('/login'),
                child: Text('Masuk', style: GoogleFonts.nunito(
                  color: t.accent, fontSize: 13, fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  decorationColor: t.accent,
                )),
              ),
            ]).animate().fadeIn(delay: 460.ms),
            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final BloomTheme t;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _Field(this.label, this.ctrl, this.t,
      {required this.icon, required this.hint,
       this.keyboardType, this.validator});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.nunito(
          fontSize: 13, fontWeight: FontWeight.w700, color: t.textPrimary)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: GoogleFonts.nunito(color: t.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: t.accent, size: 20),
        ),
        validator: validator,
      ),
    ],
  );
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final BloomTheme t;
  final bool obscure;
  final VoidCallback toggle;
  final String? Function(String?)? validator;
  const _PasswordField(this.label, this.ctrl, this.t, this.obscure, this.toggle, {this.validator});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.nunito(
          fontSize: 13, fontWeight: FontWeight.w700, color: t.textPrimary)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        style: GoogleFonts.nunito(color: t.textPrimary),
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon: Icon(Icons.lock_outline, color: t.accent, size: 20),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
                color: t.textHint, size: 20),
            onPressed: toggle,
          ),
        ),
        validator: validator,
      ),
    ],
  );
}

class _Blob extends StatelessWidget {
  final double size; final Color color;
  const _Blob(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}