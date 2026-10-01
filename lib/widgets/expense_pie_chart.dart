import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final double totalAmount;

  const ExpensePieChart({
    Key? key,
    required this.categoryData,
    required this.totalAmount,
  }) : super(key: key);

  static final List<Color> sliceColors = [
    const Color(0xFF0284C7), // Sky Blue
    const Color(0xFF10B981), // Emerald Green
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF64748B), // Slate
  ];

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty || totalAmount <= 0) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.black26),
            SizedBox(height: 8),
            Text('Chưa có dữ liệu chi tiêu', style: TextStyle(color: Colors.black45)),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final keys = categoryData.keys.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CustomPaint(
            painter: _PieChartPainter(
              data: categoryData,
              total: totalAmount,
              colors: sliceColors,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng chi',
                    style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(keys.length, (index) {
            final category = keys[index];
            final amount = categoryData[category] ?? 0;
            final percentage = (amount / totalAmount * 100).toStringAsFixed(1);
            final color = sliceColors[index % sliceColors.length];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  '$category ($percentage%)',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double total;
  final List<Color> colors;

  _PieChartPainter({
    required this.data,
    required this.total,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 26.0;

    double startAngle = -pi / 2;

    int colorIndex = 0;
    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.data != data;
  }
}
