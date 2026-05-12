import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds initial data into Firestore if collections are empty.
/// Also migrates existing products that are missing the `stock` field.
/// Safe to call on every app launch.
class FirebaseSeeder {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedIfEmpty() async {
    await Future.wait([
      _seedAttributes(),
      _seedCoupons(),
      _fixProductsStock(),
    ]);
  }

  // ──────────────────────────── PRODUCT STOCK MIGRATION ──────────────────────

  /// Sets `stock = 100` for every product whose stock is 0 or missing,
  /// so products stop appearing as permanently out-of-stock.
  static Future<void> _fixProductsStock() async {
    final snap = await _db.collection('products').get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    bool hasUpdates = false;

    for (final doc in snap.docs) {
      final data = doc.data();
      final stock = data['stock'];
      // Fix if field is missing, null, or zero
      if (stock == null || (stock is int && stock <= 0) || (stock is num && stock <= 0)) {
        batch.update(doc.reference, {'stock': 100});
        hasUpdates = true;
      }
    }

    if (hasUpdates) await batch.commit();
  }

  // ─────────────────────────────── ATTRIBUTES ──────────────────────────────

  static Future<void> _seedAttributes() async {
    final snap = await _db.collection('attributes').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final now = Timestamp.now();

    final List<Map<String, dynamic>> data = [
      {
        'name': 'Loại vật liệu',
        'attributeValues': [
          'Xi măng',
          'Gạch',
          'Cát',
          'Đá dăm',
          'Thép',
          'Gỗ',
          'Nhựa',
          'Kính',
          'Sơn',
          'Ngói',
        ],
        'isActive': true,
        'isSearchable': true,
        'isFilterable': true,
        'isColorAttribute': false,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Màu sắc',
        'attributeValues': [
          'Trắng',
          'Xám',
          'Đỏ',
          'Vàng nhạt',
          'Xanh dương',
          'Nâu đất',
          'Đen',
          'Bạc',
        ],
        'isActive': true,
        'isSearchable': true,
        'isFilterable': true,
        'isColorAttribute': true,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Kích thước gạch (cm)',
        'attributeValues': [
          '20x20',
          '30x30',
          '40x40',
          '60x60',
          '80x80',
          '30x60',
          '40x80',
          '60x120',
        ],
        'isActive': true,
        'isSearchable': false,
        'isFilterable': true,
        'isColorAttribute': false,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Độ dày (mm)',
        'attributeValues': ['5', '8', '10', '12', '15', '20', '25', '30'],
        'isActive': true,
        'isSearchable': false,
        'isFilterable': true,
        'isColorAttribute': false,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Mác xi măng',
        'attributeValues': ['PCB30', 'PCB40', 'PC50', 'Portland'],
        'isActive': true,
        'isSearchable': true,
        'isFilterable': true,
        'isColorAttribute': false,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Loại thép',
        'attributeValues': [
          'Thép tròn',
          'Thép hộp vuông',
          'Thép hộp chữ nhật',
          'Thép chữ I',
          'Thép chữ U',
          'Thép tấm',
        ],
        'isActive': true,
        'isSearchable': true,
        'isFilterable': true,
        'isColorAttribute': false,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Cấp độ bền bê tông',
        'attributeValues': ['B15', 'B20', 'B25', 'B30', 'B35', 'B40'],
        'isActive': true,
        'isSearchable': false,
        'isFilterable': true,
        'isColorAttribute': false,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Tiêu chuẩn chất lượng',
        'attributeValues': ['TCVN', 'ISO 9001', 'JIS', 'ASTM', 'EN'],
        'isActive': true,
        'isSearchable': true,
        'isFilterable': false,
        'isColorAttribute': false,
        'createdAt': now,
        'updatedAt': now,
      },
    ];

    final batch = _db.batch();
    for (final item in data) {
      batch.set(_db.collection('attributes').doc(), item);
    }
    await batch.commit();
  }

  // ──────────────────────────────── COUPONS ────────────────────────────────

  static Future<void> _seedCoupons() async {
    final snap = await _db.collection('coupons').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final now = DateTime.now();
    final endDefault = now.add(const Duration(days: 30));
    final endSummer = DateTime(now.year, 8, 31);
    final endYear = DateTime(now.year, 12, 31);

    final List<Map<String, dynamic>> data = [
      {
        'code': 'VLX10',
        'description': 'Giảm 10% cho tất cả đơn hàng vật liệu xây dựng',
        'discountType': 'percentage',
        'discountValue': 10.0,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDefault),
        'usageLimit': 500,
        'usageCount': 38,
        'isActive': true,
        'createdAt': Timestamp.fromDate(now),
        'updateAt': Timestamp.fromDate(now),
      },
      {
        'code': 'CEMENT50K',
        'description': 'Giảm 50,000đ cho đơn hàng xi măng từ 500kg trở lên',
        'discountType': 'flat',
        'discountValue': 50000.0,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDefault),
        'usageLimit': 200,
        'usageCount': 12,
        'isActive': true,
        'createdAt': Timestamp.fromDate(now),
        'updateAt': Timestamp.fromDate(now),
      },
      {
        'code': 'VLXVIP20',
        'description': 'Ưu đãi khách VIP — giảm 20% toàn bộ đơn hàng',
        'discountType': 'percentage',
        'discountValue': 20.0,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endYear),
        'usageLimit': 50,
        'usageCount': 5,
        'isActive': false,
        'createdAt': Timestamp.fromDate(now),
        'updateAt': Timestamp.fromDate(now),
      },
      {
        'code': 'NEWCUST100K',
        'description': 'Tặng 100,000đ cho khách hàng mới lần đầu mua hàng',
        'discountType': 'flat',
        'discountValue': 100000.0,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endYear),
        'usageLimit': 1000,
        'usageCount': 124,
        'isActive': true,
        'createdAt': Timestamp.fromDate(now),
        'updateAt': Timestamp.fromDate(now),
      },
      {
        'code': 'SUMMER15',
        'description': 'Ưu đãi mùa hè — giảm 15% đơn hàng sơn và vật liệu trang trí',
        'discountType': 'percentage',
        'discountValue': 15.0,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endSummer),
        'usageLimit': 300,
        'usageCount': 89,
        'isActive': true,
        'createdAt': Timestamp.fromDate(now),
        'updateAt': Timestamp.fromDate(now),
      },
      {
        'code': 'GACH30K',
        'description': 'Giảm 30,000đ đơn hàng gạch ốp lát từ 50m² trở lên',
        'discountType': 'flat',
        'discountValue': 30000.0,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDefault),
        'usageLimit': 150,
        'usageCount': 0,
        'isActive': false,
        'createdAt': Timestamp.fromDate(now),
        'updateAt': Timestamp.fromDate(now),
      },
    ];

    final batch = _db.batch();
    for (final item in data) {
      batch.set(_db.collection('coupons').doc(), item);
    }
    await batch.commit();
  }
}
