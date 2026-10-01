import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../services/database_helper.dart';
import '../services/regex_parser.dart';

class ReceiptReviewScreen extends StatefulWidget {
  final String imagePath;
  final ReceiptParseResult parseResult;

  const ReceiptReviewScreen({
    Key? key,
    required this.imagePath,
    required this.parseResult,
  }) : super(key: key);

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  final List<String> _categories = [
    'Ăn uống & Cà phê',
    'Đi chợ & Tạp hóa',
    'Học tập & Giáo trình',
    'Di chuyển & Xăng xe',
    'Chi tiêu khác',
  ];

  bool _isSaving = false;
  bool _showRawText = false;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.parseResult.merchantName);
    
    // Format initial amount
    final amountInt = widget.parseResult.totalAmount.toInt();
    _amountController = TextEditingController(text: amountInt.toString());

    _selectedDate = widget.parseResult.date;
    _selectedCategory = _categories.contains(widget.parseResult.category)
        ? widget.parseResult.category
        : _categories.first;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final cleanAmountStr = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final totalAmount = double.tryParse(cleanAmountStr) ?? 0.0;

    final expense = ReceiptExpense(
      merchantName: _merchantController.text.trim(),
      totalAmount: totalAmount,
      date: _selectedDate,
      category: _selectedCategory,
      imagePath: widget.imagePath,
      rawOcrText: widget.parseResult.rawText,
    );

    await DatabaseHelper.instance.insertExpense(expense);

    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu hóa đơn vào cơ sở dữ liệu SQLite thành công!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Xác nhận & Kiểm tra Hóa đơn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt image preview
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                  image: DecorationImage(
                    image: FileImage(File(widget.imagePath)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Đã nhận diện bởi Google ML Kit',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Form fields card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tên địa điểm / Cửa hàng', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _merchantController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.storefront, color: Color(0xFF0284C7)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên cửa hàng' : null,
                    ),

                    const SizedBox(height: 16),

                    const Text('Tổng số tiền thanh toán (VNĐ)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF10B981)),
                        suffixText: 'đ',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập số tiền' : null,
                    ),

                    const SizedBox(height: 16),

                    const Text('Ngày trên hóa đơn', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF0284C7)),
                                const SizedBox(width: 10),
                                Text(dateFormat.format(_selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Text('Thay đổi', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Danh mục chi tiêu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFFF59E0B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Expandable Raw OCR Text (For Teacher / Student audit)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ExpansionTile(
                  title: const Text(
                    'Xem văn bản gốc ML Kit trích xuất',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.parseResult.rawText.isEmpty ? '(Không có văn bản)' : widget.parseResult.rawText,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF334155)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Đang lưu vào SQLite...' : 'Lưu Hóa Đơn Vào SQLite',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
