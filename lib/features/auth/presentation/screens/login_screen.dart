import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final t    = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: Stack(children: [
        // Decorative blobs
        Positioned(top: -60, right: -60,
            child: _Blob(200, t.accent.withOpacity(0.15))),
        Positioned(top: 100, left: -40,
            child: _Blob(120, t.info.withOpacity(0.1))),
        Positioned(bottom: 100, right: -40,
            child: _Blob(150, t.accent.withOpacity(0.1))),

        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),

            // Logo
            Column(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: t.accent, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: t.accent.withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 8),
                  )],
                ),
                child: Center(child: Text('🌸',
                    style: const TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: 10),
              Text('Bloom', style: GoogleFonts.nunito(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: t.textPrimary)),
              Text('JavaScript Learning', style: GoogleFonts.nunito(
                  fontSize: 13, color: t.textSecondary,
                  fontWeight: FontWeight.w500)),
            ]).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(.8,.8)),

            const SizedBox(height: 32),

            Text('Selamat Datang! 👋', style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: t.textPrimary))
                .animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 6),
            Text('Masuk dan lanjutkan belajar JavaScript-mu',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 13, color: t.textSecondary))
                .animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 28),

            // Form card
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
                    _Label('Email', t),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.nunito(color: t.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'nama@email.com',
                        prefixIcon: Icon(Icons.email_outlined, color: t.accent, size: 20),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email tidak valid' : null,
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 14),
                    _Label('Password', t),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: GoogleFonts.nunito(color: t.textPrimary),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline, color: t.accent, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                              color: t.textHint, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min. 6 karakter' : null,
                    ).animate().fadeIn(delay: 350.ms),

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
                            : Text('Masuk', style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800, fontSize: 15,
                                color: t.accentText))),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.1),

            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Belum punya akun? ', style: GoogleFonts.nunito(
                  color: t.textSecondary, fontSize: 13)),
              Bounceable(
                onTap: () => context.go('/register'),
                child: Text('Daftar Sekarang', style: GoogleFonts.nunito(
                  color: t.accent, fontSize: 13,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  decorationColor: t.accent,
                )),
              ),
            ]).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final BloomTheme t;
  const _Label(this.text, this.t);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.nunito(
      fontSize: 13, fontWeight: FontWeight.w700, color: t.textPrimary));
}

class _Blob extends StatelessWidget {
  final double size; final Color color;
  const _Blob(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}