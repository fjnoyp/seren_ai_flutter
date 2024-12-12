import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/*
Initial Charts:

What problem are we solving? - Administrator visibility on what is being done overally and by project 

1. Task Distribution by Team Member - just # of tasks assigned per person 

ISSUE - we don't know when task status changed so cannot graph it ... 

2. Task due dates over time + task title 

3. # of tasks by status 
  
*/

class ChartsPage extends HookConsumerWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = useState([
      _SalesData('Jan', 35),
      _SalesData('Feb', 28),
      _SalesData('Mar', 34),
      _SalesData('Apr', 32),
      _SalesData('May', 40)
    ]);

    return Scaffold(
        appBar: AppBar(
          title: const Text('FL Chart Example'),
        ),
        body: Column(children: [
          AspectRatio(
            aspectRatio: 2,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.value.length) {
                          return Text(data.value[value.toInt()].year);
                        }
                        return const Text('');
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.value.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.sales);
                    }).toList(),
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.value.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.sales);
                      }).toList(),
                      isCurved: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          )
        ]));
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}