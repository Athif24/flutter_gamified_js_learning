import 'package:flutter/material.dart';

class ActionBtnData {
  final String label;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const ActionBtnData({
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.textColor,
    this.isLoading = false,
    this.onTap,
  });
}