import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/config/theme_config.dart';

class RatingCircle extends StatelessWidget {
  final double rating;
  final double size;
  final double lineWidth;
  final bool showAnimation;
  final TextStyle? textStyle;

  const RatingCircle({
    super.key,
    required this.rating,
    this.size = 60,
    this.lineWidth = 5,
    this.showAnimation = true,
    this.textStyle,
  });

  Color _getRatingColor(double rating) {
    if (rating >= 7.0) {
      return const Color(0xFF21D07A);
    } else if (rating >= 5.0) {
      return const Color(0xFFD2D531);
    } else {
      return const Color(0xFFDB2360);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = rating / 10;
    final displayPercentage = (rating * 10).round();
    final ratingColor = _getRatingColor(rating);

    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: lineWidth,
      percent: percentage.clamp(0.0, 1.0),
      center: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$displayPercentage',
              style: textStyle ??
                  TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.28,
                  ),
            ),
            TextSpan(
              text: '%',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.14,
              ),
            ),
          ],
        ),
      ),
      progressColor: ratingColor,
      backgroundColor: ratingColor.withOpacity(0.3),
      circularStrokeCap: CircularStrokeCap.round,
      animation: showAnimation,
      animationDuration: 1000,
    );
  }
}

class RatingCircleSmall extends StatelessWidget {
  final double rating;

  const RatingCircleSmall({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RatingCircle(
        rating: rating,
        size: 40,
        lineWidth: 3,
        showAnimation: false,
      ),
    );
  }
}
