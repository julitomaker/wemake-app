import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = AppTheme.radiusXl,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.glassBlur,
            sigmaY: AppTheme.glassBlur,
          ),
          child: Container(
            padding: padding,
            decoration: AppTheme.glassBoxDecoration(radius: radius).copyWith(
              gradient: gradient ?? AppTheme.glassSurface,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
