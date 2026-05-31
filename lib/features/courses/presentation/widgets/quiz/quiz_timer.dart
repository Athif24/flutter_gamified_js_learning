import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class TimerChip extends StatelessWidget {
  final String display;
  final Color color;
  final BloomTheme t;
  const TimerChip({
    super.key,
    required this.display,
    required this.color,
    required this.t,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: S.scale(context, 10),
      vertical: S.scale(context, 5),
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(S.scale(context, 50)),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, color: color, size: S.scale(context, 14)),
        SizedBox(width: S.scale(context, 4)),
        Text(
          display,
          style: GoogleFonts.firaCode(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: S.font(context, 12),
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

class _QuizTimerState extends State<QuizTimer>
    with SingleTickerProviderStateMixin {
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
        if (mounted) {
          setState(() {
            _remainingSeconds--;
            if (_remainingSeconds <= 60) {
              _pulseController.forward(from: 0);
            }
          });
        }
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
    final color = _isWarning ? widget.t.error : widget.t.primary;
    return Semantics(
      label: 'Waktu tersisa $_display',
      liveRegion: true,
      child: _pulseController.isAnimating
          ? ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: TimerChip(display: _display, color: color, t: widget.t),
            )
          : TimerChip(display: _display, color: color, t: widget.t),
    );
  }
}