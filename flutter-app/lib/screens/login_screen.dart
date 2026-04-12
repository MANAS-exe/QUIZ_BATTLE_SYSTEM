import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../theme/colors.dart';

const _coral   = appCoral;
const _bg      = appBg;
const _surface = appSurface;

// ─────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────
//
// WHY this layout:
//   Google Sign-In is the primary path — one tap, no typing, no forgotten
//   passwords. The email/password section is available as a fallback for
//   users who prefer it or don't have a Google account, but it's intentionally
//   secondary (collapsed behind a text link).
//
// UX principles applied:
//   - Primary action (Google) is large, immediately visible, above the fold
//   - Secondary action (email/password) requires an extra tap (reduces friction
//     for the happy path while not hiding the option for power users)
//   - Error messages use shake animation so they draw attention without being
//     annoying if the user succeeds on first try
//   - Loading states on both buttons prevent double-submits

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _showEmailForm = false;  // collapse email/password by default
  bool _isRegister    = false;  // toggle between login and register
  bool _googleLoading = false;
  bool _emailLoading  = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saved = await ref.read(authProvider.notifier).getSavedUsername();
      if (saved != null && mounted) _usernameCtrl.text = saved;
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Google sign-in ─────────────────────────────────────────────

  Future<void> _onGoogleSignIn() async {
    setState(() { _googleLoading = true; _error = null; });
    final err = await ref.read(authProvider.notifier).googleSignIn();
    if (!mounted) return;
    if (err != null) {
      setState(() { _googleLoading = false; _error = err; });
    } else {
      context.goNamed('home');
    }
  }

  // ── Email/password ─────────────────────────────────────────────

  Future<void> _onEmailSubmit() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter username and password');
      return;
    }
    setState(() { _emailLoading = true; _error = null; });
    final notifier = ref.read(authProvider.notifier);
    final err = _isRegister
        ? await notifier.register(username, password)
        : await notifier.login(username, password);
    if (!mounted) return;
    if (err != null) {
      setState(() { _emailLoading = false; _error = err; });
    } else {
      context.goNamed('home');
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 20),
                _buildHeadline(),
                const SizedBox(height: 40),
                _buildGoogleButton(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildEmailToggle(),
                if (_showEmailForm) ...[
                  const SizedBox(height: 16),
                  _buildEmailForm(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _buildError(),
                ],
                const SizedBox(height: 40),
                _buildTermsNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _coral.withValues(alpha: 0.15),
        border: Border.all(color: _coral.withValues(alpha: 0.4), width: 2),
      ),
      child: const Icon(Icons.bolt_rounded, color: _coral, size: 44),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildHeadline() {
    return Column(
      children: [
        const Text(
          'Quiz Battle',
          style: TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 6),
        Text(
          'Challenge friends. Climb the ranks.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45), fontSize: 14),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
      ],
    );
  }

  /// Primary action — large Google button with official branding colours.
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _googleLoading ? null : _onGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
        ),
        child: _googleLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Color(0xFF1F1F1F), strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleLogo(),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F)),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 450.ms, duration: 400.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
      ],
    ).animate().fadeIn(delay: 550.ms, duration: 400.ms);
  }

  /// Tap to expand the email/password form.
  Widget _buildEmailToggle() {
    return GestureDetector(
      onTap: () => setState(() {
        _showEmailForm = !_showEmailForm;
        _error = null;
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Use email / password',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(
            _showEmailForm
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: Colors.white38,
            size: 18,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _usernameCtrl,
          hint: 'Username',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _passwordCtrl,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _emailLoading ? null : _onEmailSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _coral,
              disabledBackgroundColor: _coral.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _emailLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    _isRegister ? 'Register' : 'Login',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() { _isRegister = !_isRegister; _error = null; }),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _isRegister
                      ? 'Already have an account? '
                      : "Don't have an account? ",
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                ),
                TextSpan(
                  text: _isRegister ? 'Login' : 'Register',
                  style: const TextStyle(
                      color: _coral, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildError() {
    return Text(
      _error!,
      style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 13),
      textAlign: TextAlign.center,
    ).animate().fadeIn(duration: 200.ms).shakeX(hz: 3, amount: 4);
  }

  Widget _buildTermsNote() {
    return Text(
      'By continuing you agree to our Terms of Service\nand Privacy Policy.',
      style: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 11,
          height: 1.6),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 700.ms, duration: 400.ms);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      onSubmitted: (_) => _onEmailSubmit(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: _surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _coral, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// GOOGLE LOGO WIDGET
// ─────────────────────────────────────────
// Drawn with Canvas (no external asset needed).
// Official Google "G" colours are used for brand compliance.

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Background circle
    canvas.drawCircle(
        center, r, Paint()..color = Colors.white);

    // Four coloured arcs (simplified G logo)
    final strokeW = size.width * 0.18;
    final arcR = r - strokeW / 2;
    final rect = Rect.fromCircle(center: center, radius: arcR);

    void arc(double start, double sweep, Color color) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
    }

    const pi = 3.14159265;
    arc(-pi / 6, pi / 2 + pi / 6, const Color(0xFF4285F4));       // blue (right)
    arc(pi / 3, pi / 2, const Color(0xFF34A853));                   // green (bottom)
    arc(5 * pi / 6, pi / 2, const Color(0xFFFBBC05));               // yellow (left)
    arc(4 * pi / 3, pi / 2 + pi / 6, const Color(0xFFEA4335));      // red (top)

    // Horizontal bar of the G
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(center.dx, center.dy - strokeW * 0.1),
      Offset(center.dx + arcR, center.dy - strokeW * 0.1),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
