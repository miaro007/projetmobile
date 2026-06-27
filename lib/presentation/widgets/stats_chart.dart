import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsChart extends StatelessWidget {
  const StatsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                  return Text(titles[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 5),
            _makeGroupData(1, 8),
            _makeGroupData(2, 3),
            _makeGroupData(3, 12),
            _makeGroupData(4, 7),
            _makeGroupData(5, 18),
            _makeGroupData(6, 10),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF2E7D32),
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
