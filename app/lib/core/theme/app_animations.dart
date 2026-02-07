import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 900);

  static const Curve easeInOutOk = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}
