import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../services/database_helper.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/expense_bar_chart.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ReceiptExpense> _expenses = [];
  Map<String, double> _categoryData = {};
  double _totalSpending = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final expenses = await DatabaseHelper.instance.getAllExpenses();
    final categoryData = await DatabaseHelper.instance.getSpendingByCategory();
    final total = await DatabaseHelper.instance.getTotalSpending();

    setState(() {
      _expenses = expenses;
      _categoryData = categoryData;
      _totalSpending = total;
      _isLoading = false;
    });
  }

  Future<void> _deleteExpense(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa hóa đơn?'),
        content: Text('Bạn có chắc chắn muốn xóa bản ghi "$name" khỏi cơ sở dữ liệu SQLite?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteExpense(id);
      _loadData();
    }
  }

  void _openScanScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'VKU EXPENSE TRACKER',
              style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
            ),
            Text(
              'Quản Lý Chi Tiêu & OCR',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            onPressed: _loadData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng chi tiêu đã ghi nhận',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_expenses.length} hóa đơn',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormat.format(_totalSpending),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Action OCR Banner
                    InkWell(
                      onTap: _openScanScreen,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.document_scanner, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Quét hóa đơn bằng Camera AI',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF065F46)),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Google ML Kit tự động trích xuất số tiền & ngày',
                                    style: TextStyle(color: Color(0xFF047857), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF059669)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Custom Canvas Pie Chart Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Phân tích theo danh mục',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                'CustomPainter',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ExpensePieChart(
                            categoryData: _categoryData,
                            totalAmount: _totalSpending,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Custom Canvas Bar Chart
                    ExpenseBarChart(expenses: _expenses),

                    const SizedBox(height: 28),

                    // Recent Invoices List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lịch sử hóa đơn',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '${_expenses.length} mục',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_expenses.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Column(
                          children: const [
                            Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 10),
                            Text('Chưa có hóa đơn nào được lưu trong SQLite', style: TextStyle(color: Color(0xFF64748B))),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _expenses.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final item = _expenses[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.receipt, color: Color(0xFF0284C7), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.merchantName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            dateFormat.format(item.date),
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.category,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormat.format(item.totalAmount),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () => _deleteExpense(item.id!, item.merchantName),
                                      child: const Text('Xóa', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanScreen,
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text('Quét Hóa Đơn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
