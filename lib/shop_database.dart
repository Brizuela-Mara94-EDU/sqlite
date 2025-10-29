import 'package:path/path.dart';
import 'package:sqlite/models.dart';
import 'package:sqflite/sqflite.dart';

class ShopDatabase {
  static final ShopDatabase instance = ShopDatabase._init();
  static Database? _database;
  ShopDatabase._init();

  final String tableCartItems = 'cart_items';
  final String tableProducts = 'products';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _onCreateDB, onUpgrade: _onUpgradeDB);
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableCartItems ADD COLUMN image TEXT');
    }
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE $tableCartItems(
id INTEGER PRIMARY KEY,
name TEXT,
price INTEGER,
quantity INTEGER,
image TEXT
)
''');

    await db.execute('''
CREATE TABLE $tableProducts(
id INTEGER PRIMARY KEY,
name TEXT,
description TEXT,
price INTEGER,
image TEXT
)
''');
  }

  // Methods for Cart
  Future<void> insert(CartItem item) async {
    final db = await instance.database;
    await db.insert(
      tableCartItems,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItem>> getAllItems() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        c.id,
        p.name,
        p.price,
        c.quantity,
        p.image
      FROM $tableCartItems c
      JOIN $tableProducts p ON c.id = p.id
    ''');

    return List.generate(maps.length, (i) {
      return CartItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        price: maps[i]['price'],
        image: maps[i]['image'] ?? '',
        quantity: maps[i]['quantity'],
      );
    });
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(tableCartItems, where: "id = ?", whereArgs: [id]);
  }

  Future<int> update(CartItem item) async {
    final db = await instance.database;
    return await db.update(
      tableCartItems,
      item.toMap(),
      where: "id=?",
      whereArgs: [item.id],
    );
  }

  // Methods for Products
  Future<void> insertProduct(Product product) async {
    final db = await instance.database;
    await db.insert(
      tableProducts,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableProducts);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      tableProducts,
      product.toMap(),
      where: "id = ?",
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(tableProducts, where: "id = ?", whereArgs: [id]);
  }
}
