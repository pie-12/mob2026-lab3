import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/receipt.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vku_expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant_name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        image_path TEXT,
        raw_ocr_text TEXT
      )
    ''');
  }

  Future<int> insertExpense(ReceiptExpense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ReceiptExpense>> getAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => ReceiptExpense.fromMap(json)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalSpending() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(total_amount) as total FROM expenses');
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<Map<String, double>> getSpendingByCategory() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT category, SUM(total_amount) as total 
      FROM expenses 
      GROUP BY category
    ''');

    final Map<String, double> categoryMap = {};
    for (var row in result) {
      final category = row['category'] as String? ?? 'Khác';
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      categoryMap[category] = total;
    }
    return categoryMap;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
