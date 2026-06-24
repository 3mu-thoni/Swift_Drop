import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';

final analyticsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ApiService();
  final response = await api.get('/admin/analytics');
  return response.data;
});

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(analyticsProvider),
          ),
        ],
      ),
      body: analytics.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: Color(0xFFFF6B35)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 12),
              Text('Error: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(analyticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orders per day chart
              _ChartCard(
                title: 'Orders — Last 7 Days',
                subtitle: 'Daily order volume',
                child: _OrdersPerDayChart(
                  data: List<Map<String, dynamic>>.from(
                      data['ordersPerDay'] ?? []),
                ),
              ),
              const SizedBox(height: 16),

              // Orders by status pie chart
              Row(
                children: [
                  Expanded(
                    child: _ChartCard(
                      title: 'By Status',
                      subtitle: 'Order breakdown',
                      child: _StatusPieChart(
                        data: List<Map<String, dynamic>>.from(
                            data['ordersByStatus'] ?? []),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ChartCard(
                      title: 'By Payment',
                      subtitle: 'Payment methods',
                      child: _PaymentPieChart(
                        data: List<Map<String, dynamic>>.from(
                            data['ordersByPayment'] ?? []),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Top shops bar chart
              _ChartCard(
                title: 'Top Shops',
                subtitle: 'By number of orders',
                child: _TopShopsChart(
                  data: List<Map<String, dynamic>>.from(
                      data['topShops'] ?? []),
                ),
              ),
              const SizedBox(height: 16),

              // Users by role
              _ChartCard(
                title: 'Users by Role',
                subtitle: 'Platform user distribution',
                child: _UsersRoleChart(
                  data: List<Map<String, dynamic>>.from(
                      data['usersByRole'] ?? []),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chart card wrapper ──
class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Orders per day line chart ──
class _OrdersPerDayChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _OrdersPerDayChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No data yet',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        (e.value['count'] ?? 0).toDouble(),
      );
    }).toList();

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: const Color(0xFFEEEFF2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final dateStr =
                      data[index]['_id'] as String? ?? '';
                  final parts = dateStr.split('-');
                  final label = parts.length >= 3
                      ? '${parts[1]}/${parts[2]}'
                      : dateStr;
                  return Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B7280),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFFF6B35),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFFFF6B35),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status pie chart ──
class _StatusPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _StatusPieChart({required this.data});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF3B82F6);
      case 'preparing': return const Color(0xFF8B5CF6);
      case 'on_the_way': return const Color(0xFF2EC4B6);
      case 'delivered': return const Color(0xFF22C55E);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text('No data yet',
              style: TextStyle(color: Color(0xFF6B7280))),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: data.map((item) {
                  final status = item['_id'] as String? ?? '';
                  final count =
                      (item['count'] ?? 0).toDouble();
                  return PieChartSectionData(
                    value: count,
                    color: _statusColor(status),
                    title: count.toInt().toString(),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: data.map((item) {
              final status = item['_id'] as String? ?? '';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    status.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Payment pie chart ──
class _PaymentPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _PaymentPieChart({required this.data});

  Color _paymentColor(String method) {
    switch (method) {
      case 'mpesa': return const Color(0xFF00A651);
      case 'cash': return const Color(0xFF3B82F6);
      case 'card': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text('No data yet',
              style: TextStyle(color: Color(0xFF6B7280))),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: data.map((item) {
                  final method = item['_id'] as String? ?? '';
                  final count =
                      (item['count'] ?? 0).toDouble();
                  return PieChartSectionData(
                    value: count,
                    color: _paymentColor(method),
                    title: count.toInt().toString(),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: data.map((item) {
              final method = item['_id'] as String? ?? '';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _paymentColor(method),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    method,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Top shops bar chart ──
class _TopShopsChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _TopShopsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('No data yet',
              style: TextStyle(color: Color(0xFF6B7280))),
        ),
      );
    }

    final maxY = data
        .map((e) => (e['orderCount'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY + 2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final name =
                      data[index]['name'] as String? ?? '';
                  final short = name.length > 6
                      ? '${name.substring(0, 6)}...'
                      : name;
                  return Text(
                    short,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B7280),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: const Color(0xFFEEEFF2),
              strokeWidth: 1,
            ),
          ),
          barGroups: data.asMap().entries.map((e) {
            final colors = [
              const Color(0xFFFF6B35),
              const Color(0xFF3B82F6),
              const Color(0xFF22C55E),
              const Color(0xFF8B5CF6),
              const Color(0xFF2EC4B6),
            ];
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: (e.value['orderCount'] ?? 0)
                      .toDouble(),
                  color: colors[e.key % colors.length],
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Users by role chart ──
class _UsersRoleChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _UsersRoleChart({required this.data});

  Color _roleColor(String role) {
    switch (role) {
      case 'customer': return const Color(0xFF22C55E);
      case 'rider': return const Color(0xFF3B82F6);
      case 'admin': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('No data yet',
              style: TextStyle(color: Color(0xFF6B7280))),
        ),
      );
    }

    final total = data
        .map((e) => (e['count'] ?? 0) as int)
        .fold(0, (a, b) => a + b);

    return Column(
      children: data.map((item) {
        final role = item['_id'] as String? ?? '';
        final count = (item['count'] ?? 0) as int;
        final percent =
            total > 0 ? (count / total * 100).toInt() : 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _roleColor(role),
                    ),
                  ),
                  Text(
                    '$count ($percent%)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? count / total : 0,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _roleColor(role)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}