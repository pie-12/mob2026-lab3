class ReceiptExpense {
  final int? id;
  final String merchantName;
  final double totalAmount;
  final DateTime date;
  final String category;
  final String? imagePath;
  final String? rawOcrText;

  ReceiptExpense({
    this.id,
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    required this.category,
    this.imagePath,
    this.rawOcrText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant_name': merchantName,
      'total_amount': totalAmount,
      'date': date.toIso8601String(),
      'category': category,
      'image_path': imagePath,
      'raw_ocr_text': rawOcrText,
    };
  }

  factory ReceiptExpense.fromMap(Map<String, dynamic> map) {
    return ReceiptExpense(
      id: map['id'] as int?,
      merchantName: map['merchant_name'] as String? ?? 'Cửa hàng không xác định',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null 
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now() 
          : DateTime.now(),
      category: map['category'] as String? ?? 'Khác',
      imagePath: map['image_path'] as String?,
      rawOcrText: map['raw_ocr_text'] as String?,
    );
  }

  ReceiptExpense copyWith({
    int? id,
    String? merchantName,
    double? totalAmount,
    DateTime? date,
    String? category,
    String? imagePath,
    String? rawOcrText,
  }) {
    return ReceiptExpense(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }
}
