import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../tasks/data/task_repository.dart';
import '../../reports/data/report_repository.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: reportsAsync.when(
        data: (reports) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(context, reports),
              const SizedBox(height: 24),
              Text(
                'Task Completion Trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildCompletionChart(reports),
              const SizedBox(height: 24),
              Text(
                'Quality Ratings Distribution',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildQualityChart(reports),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, List<dynamic> reports) {
    final totalReports = reports.length;
    final avgQuality = reports.isEmpty ? 0.0 : _calculateAverageQuality(reports);
    
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blue.shade600,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.assignment_turned_in, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '$totalReports',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total Reports',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Colors.green.shade600,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    avgQuality.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Avg Quality',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionChart(List<dynamic> reports) {
    if (reports.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No data available'),
        ),
      );
    }

    // Group reports by day
    final Map<DateTime, int> dailyCounts = {};
    for (var report in reports) {
      final date = DateTime(
        report.submittedAt.year,
        report.submittedAt.month,
        report.submittedAt.day,
      );
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyCounts[entry.value]!.toDouble());
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityChart(List<dynamic> reports) {
    if (reports.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No quality data available'),
        ),
      );
    }

    // Count quality ratings (1-5)
    final Map<int, int> qualityCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var report in reports) {
      for (var result in report.results) {
        if (result.value is int && result.value >= 1 && result.value <= 5) {
          qualityCounts[result.value] = (qualityCounts[result.value] ?? 0) + 1;
        }
      }
    }

    final sections = qualityCounts.entries.map((entry) {
      final value = entry.value.toDouble();
      return PieChartSectionData(
        value: value,
        title: value > 0 ? '${entry.key}★' : '',
        color: _getQualityColor(entry.key),
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  double _calculateAverageQuality(List<dynamic> reports) {
    int totalRatings = 0;
    int count = 0;
    
    for (var report in reports) {
      for (var result in report.results) {
        if (result.value is int && result.value >= 1 && result.value <= 5) {
          totalRatings += result.value as int;
          count++;
        }
      }
    }
    
    return count > 0 ? totalRatings / count : 0.0;
  }

  Color _getQualityColor(int rating) {
    switch (rating) {
      case 5: return Colors.green;
      case 4: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 2: return Colors.deepOrange;
      case 1: return Colors.red;
      default: return Colors.grey;
    }
  }
}
