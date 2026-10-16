import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.cardHover,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
