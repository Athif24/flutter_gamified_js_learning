import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';

class TimerChip extends StatelessWidget {
  final String display;
  final Color color;
  final BloomTheme t;
  const TimerChip({super.key, required this.display, required this.color, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          display,
          style: GoogleFonts.firaCode(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class QuizTimer extends StatefulWidget {
  final int timeLimitMinutes;
  final BloomTheme t;
  final VoidCallback onTimeUp;

  const QuizTimer({
    super.key,
    required this.timeLimitMinutes,
    required this.t,
    required this.onTimeUp,
  });

  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer> with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeLimitMinutes * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        widget.onTimeUp();
      } else {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 60) {
            _pulseController.forward(from: 0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _display {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  bool get _isWarning => _remainingSeconds <= 60;

  @override
  Widget build(BuildContext context) {
    final color = _isWarning ? widget.t.error : widget.t.accent;
    return _pulseController.isAnimating
        ? ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: TimerChip(display: _display, color: color, t: widget.t),
          )
        : TimerChip(display: _display, color: color, t: widget.t);
  }
}
