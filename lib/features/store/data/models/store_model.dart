class StoreItem {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final int price;
  final String type;
  final bool isAvailable;

  const StoreItem({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.price,
    required this.type,
    this.isAvailable = true,
  });

  factory StoreItem.fromJson(Map<String, dynamic> j) => StoreItem(
    id         : j['id']?.toString() ?? '',
    name       : j['name'] ?? '',
    description: j['description'],
    icon       : j['icon'] ?? j['imageUrl'] ?? '🎁',
    price      : (j['price'] ?? j['jewelCost'] ?? 0) as int,
    type       : j['type'] ?? 'item',
    isAvailable: j['isAvailable'] ?? j['available'] ?? true,
  );
}

class InventoryItem {
  final String id;
  final StoreItem item;
  final int quantity;
  final bool isUsed;

  const InventoryItem({
    required this.id,
    required this.item,
    required this.quantity,
    this.isUsed = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
    id      : j['id']?.toString() ?? '',
    item    : StoreItem.fromJson(j['item'] ?? j),
    quantity: (j['quantity'] ?? 1) as int,
    isUsed  : j['isUsed'] ?? j['used'] ?? false,
  );
}

class JewelBalance {
  final int balance;
  const JewelBalance({required this.balance});
  factory JewelBalance.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return JewelBalance(balance: (d['balance'] ?? d['jewels'] ?? d['amount'] ?? 0) as int);
  }
}

class JewelTransaction {
  final String id;
  final int amount;
  final String type;
  final String? description;
  final String createdAt;

  const JewelTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory JewelTransaction.fromJson(Map<String, dynamic> j) => JewelTransaction(
    id         : j['id']?.toString() ?? '',
    amount     : (j['amount'] ?? 0) as int,
    type       : j['type'] ?? 'earn',
    description: j['description'] ?? j['reason'],
    createdAt  : j['createdAt']?.toString() ?? '',
  );
}