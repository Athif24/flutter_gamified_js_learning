import 'package:flutter/material.dart';

Color darken(Color c, double amount) => Color.lerp(c, Colors.black, amount)!;
