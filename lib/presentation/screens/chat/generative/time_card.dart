import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/color_palette.dart';

class TimeCard extends StatefulWidget {
  final String location;
  final String timezone;
  final String? utcOffset;
  final String? countryFlag;

  const TimeCard({
    super.key,
    required this.location,
    required this.timezone,
    this.utcOffset,
    this.countryFlag,
  });

  @override
  State<TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat('hh:mm:ss a').format(_now);
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(_now);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.subtleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ColorPalette.amberAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.countryFlag ?? '🌐',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.location,
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.utcOffset != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorPalette.elevatedCardHover,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ColorPalette.subtleBorder),
                        ),
                        child: Text(
                          widget.utcOffset!,
                          style: const TextStyle(
                            color: ColorPalette.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormatted,
                  style: const TextStyle(
                    color: ColorPalette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  dateFormatted,
                  style: const TextStyle(
                    color: ColorPalette.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
