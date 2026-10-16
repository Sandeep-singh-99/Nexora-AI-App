import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ChartCard extends StatefulWidget {
  final String title;
  final String chartType; // 'bar' or 'line'
  final List<String> labels;
  final List<double> values;
  final String? unit;

  const ChartCard({
    super.key,
    required this.title,
    this.chartType = 'bar',
    required this.labels,
    required this.values,
    this.unit,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  late bool _isBarChart;

  @override
  void initState() {
    super.initState();
    _isBarChart = widget.chartType.toLowerCase() == 'bar';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart,
                      size: 20,
                      color: _isBarChart ? colors.primary : colors.textMuted,
                    ),
                    onPressed: () => setState(() => _isBarChart = true),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.show_chart,
                      size: 20,
                      color: !_isBarChart ? colors.primary : colors.textMuted,
                    ),
                    onPressed: () => setState(() => _isBarChart = false),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: _isBarChart ? _buildBarChart(colors) : _buildLineChart(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(AppColors colors) {
    return BarChart(
      BarChartData(
        barGroups: widget.values.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: colors.primary,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      widget.labels[index],
                      style: TextStyle(color: colors.textMuted, fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLineChart(AppColors colors) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: widget.values.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: colors.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: colors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      widget.labels[index],
                      style: TextStyle(color: colors.textMuted, fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
