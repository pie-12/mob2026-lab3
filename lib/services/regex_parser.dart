class ReceiptParseResult {
  final String merchantName;
  final double totalAmount;
  final DateTime date;
  final String category;
  final String rawText;

  ReceiptParseResult({
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    required this.category,
    required this.rawText,
  });
}

class ReceiptRegexParser {
  static ReceiptParseResult parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchantName = _extractMerchant(lines);
    final totalAmount = _extractTotal(rawText, lines);
    final date = _extractDate(rawText);
    final category = _detectCategory(rawText, merchantName);

    return ReceiptParseResult(
      merchantName: merchantName,
      totalAmount: totalAmount,
      date: date,
      category: category,
      rawText: rawText,
    );
  }

  static String _extractMerchant(List<String> lines) {
    if (lines.isEmpty) return 'Cửa hàng không xác định';

    final ignoreKeywords = [
      'hoa don', 'hóa đơn', 'bill', 'receipt', 'phieu thanh toan',
      'phiếu thanh toán', 'order', 'vat', 'so:', 'số:', 'ban:', 'bàn:'
    ];

    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      
      bool shouldIgnore = false;
      for (final kw in ignoreKeywords) {
        if (lower.contains(kw)) {
          shouldIgnore = true;
          break;
        }
      }

      // Check if line contains only numbers or symbols
      if (!shouldIgnore && line.length >= 3 && RegExp(r'[a-zA-ZÀ-ỹ]').hasMatch(line)) {
        return line;
      }
    }

    return lines.first;
  }

  static double _extractTotal(String rawText, List<String> lines) {
    // 1. Look for lines with Total keywords
    final totalKeywords = [
      'tổng cộng', 'tong cong', 'thanh toán', 'thanh toan',
      'tổng tiền', 'tong tien', 'total', 'grand total', 'amount',
      'phải trả', 'phai tra', 'tiền mặt', 'tien mat'
    ];

    double detectedTotal = 0.0;

    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final lower = line.toLowerCase();

      for (final kw in totalKeywords) {
        if (lower.contains(kw)) {
          final amount = _parseAmountFromLine(line);
          if (amount > 0) {
            return amount;
          }
          // If amount is on the next line
          if (i + 1 < lines.length) {
            final nextAmount = _parseAmountFromLine(lines[i + 1]);
            if (nextAmount > 0) return nextAmount;
          }
        }
      }
    }

    // 2. Fallback: Find all numbers with currency format and take the maximum realistic amount
    final amountPattern = RegExp(r'(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{1,2})?|\d{4,9})\s*(?:đ|vnd|vnđ|\$)?', caseSensitive: false);
    final matches = amountPattern.allMatches(rawText);

    for (final match in matches) {
      final str = match.group(1);
      if (str != null) {
        final cleanStr = str.replaceAll(RegExp(r'[^\d]'), '');
        final val = double.tryParse(cleanStr) ?? 0.0;
        if (val > detectedTotal && val < 50000000) { // filter unreasonable extremes
          detectedTotal = val;
        }
      }
    }

    return detectedTotal > 0 ? detectedTotal : 50000.0; // sensible fallback demo
  }

  static double _parseAmountFromLine(String line) {
    // Matches patterns like: 125,000 or 125.000 or 125000
    final pattern = RegExp(r'(\d{1,3}(?:[.,]\d{3})+|\d{4,9})');
    final match = pattern.firstMatch(line);
    if (match != null) {
      final str = match.group(1)!.replaceAll(RegExp(r'[.,]'), '');
      return double.tryParse(str) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _extractDate(String rawText) {
    // Match common Vietnamese / International date formats:
    // DD/MM/YYYY, DD-MM-YYYY, YYYY-MM-DD
    final datePattern = RegExp(r'\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})\b');
    final match = datePattern.firstMatch(rawText);

    if (match != null) {
      final d = int.tryParse(match.group(1)!) ?? 1;
      final m = int.tryParse(match.group(2)!) ?? 1;
      final y = int.tryParse(match.group(3)!) ?? 2026;

      try {
        return DateTime(y, m, d);
      } catch (_) {}
    }

    // Secondary pattern: DD/MM/YY
    final shortDatePattern = RegExp(r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2})\b');
    final shortMatch = shortDatePattern.firstMatch(rawText);
    if (shortMatch != null) {
      final d = int.tryParse(shortMatch.group(1)!) ?? 1;
      final m = int.tryParse(shortMatch.group(2)!) ?? 1;
      final y = 2000 + (int.tryParse(shortMatch.group(3)!) ?? 26);

      try {
        return DateTime(y, m, d);
      } catch (_) {}
    }

    return DateTime.now();
  }

  static String _detectCategory(String text, String merchant) {
    final combined = (text + ' ' + merchant).toLowerCase();

    if (combined.contains('coffee') ||
        combined.contains('cafe') ||
        combined.contains('trà sữa') ||
        combined.contains('tea') ||
        combined.contains('cơm') ||
        combined.contains('quán') ||
        combined.contains('bún') ||
        combined.contains('phở') ||
        combined.contains('căn tin') ||
        combined.contains('highlands') ||
        combined.contains('phúc long')) {
      return 'Ăn uống & Cà phê';
    }

    if (combined.contains('mart') ||
        combined.contains('siêu thị') ||
        combined.contains('chợ') ||
        combined.contains('bách hóa') ||
        combined.contains('vinmart') ||
        combined.contains('winmart') ||
        combined.contains('circle k')) {
      return 'Đi chợ & Tạp hóa';
    }

    if (combined.contains('nhà sách') ||
        combined.contains('photo') ||
        combined.contains('in ấn') ||
        combined.contains('vở') ||
        combined.contains('bút') ||
        combined.contains('giáo trình') ||
        combined.contains('văn phòng phẩm')) {
      return 'Học tập & Giáo trình';
    }

    if (combined.contains('xăng') ||
        combined.contains('petrolimex') ||
        combined.contains('grab') ||
        combined.contains('be') ||
        combined.contains('gửi xe')) {
      return 'Di chuyển & Xăng xe';
    }

    return 'Chi tiêu khác';
  }
}
