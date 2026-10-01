import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/receipt.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<ReceiptExpense> expenses;

  const ExpenseBarChart({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group last 7 expenses or items
    final displayList = expenses.take(6).toList().reversed.toList();
    final maxAmount = displayList.map((e) => e.totalAmount).fold<double>(0.0, max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Biến động các hóa đơn gần đây',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Icon(Icons.bar_chart, size: 20, color: Color(0xFF0284C7)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _BarChartPainter(
                items: displayList,
                maxVal: maxAmount > 0 ? maxAmount : 100000,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ReceiptExpense> items;
  final double maxVal;

  _BarChartPainter({required this.items, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    // Draw baseline and reference lines
    canvas.drawLine(Offset(0, size.height - 25), Offset(size.width, size.height - 25), gridPaint);
    canvas.drawLine(Offset(0, (size.height - 25) / 2), Offset(size.width, (size.height - 25) / 2), gridPaint);

    final barWidth = 24.0;
    final usableHeight = size.height - 40;
    final totalBars = items.length;
    final spacing = (size.width - (totalBars * barWidth)) / (totalBars + 1);

    final barPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalBars; i++) {
      final item = items[i];
      final x = spacing + i * (barWidth + spacing);
      final barHeight = (item.totalAmount / maxVal) * usableHeight;
      final y = (size.height - 25) - barHeight;

      // Draw rounded bar
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight > 4 ? barHeight : 4),
        const Radius.circular(6),
      );
      canvas.drawRRect(rrect, barPaint);

      // Label below bar (Date)
      final textSpan = TextSpan(
        text: DateFormat('dd/MM').format(item.date),
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w500),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.maxVal != maxVal;
  }
}
