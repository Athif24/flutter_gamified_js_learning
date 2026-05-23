class StoreItem {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final int price;
  final String type;
  final bool isAvailable;
  final int? effectValue;
  final bool isConsumable;
  final int ownedQuantity;

  const StoreItem({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.price,
    required this.type,
    this.isAvailable = true,
    this.effectValue,
    this.isConsumable = true,
    this.ownedQuantity = 0,
  });

  factory StoreItem.fromJson(Map<String, dynamic> j) => StoreItem(
    id: j['id']?.toString() ?? '',
    name: j['name'] ?? '',
    description: j['description'],
    icon: j['icon'] ?? '🎁',
    price: (j['jewel_cost'] ?? 0) as int,
    type: j['item_type']?.toString() ?? 'item',
    isAvailable: j['is_active'] ?? true,
    effectValue: j['effect_value'] as int?,
    isConsumable: j['is_consumable'] ?? true,
    ownedQuantity: (j['owned_quantity'] ?? 0) as int,
  );
}

class InventoryItem {
  final String id;
  final int itemId;
  final int quantity;
  final String? acquiredAt;
  final StoreItem? item;

  const InventoryItem({
    required this.id,
    required this.itemId,
    required this.quantity,
    this.acquiredAt,
    this.item,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
    id: j['id']?.toString() ?? '',
    itemId: (j['item_id'] ?? 0) as int,
    quantity: (j['quantity'] ?? 1) as int,
    acquiredAt: j['acquired_at']?.toString(),
    item: j['item'] != null
        ? StoreItem.fromJson(j['item'] as Map<String, dynamic>)
        : null,
  );
}

class JewelBalance {
  final int balance;
  const JewelBalance({required this.balance});
  factory JewelBalance.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return JewelBalance(balance: (d['balance'] ?? 0) as int);
  }
}

class JewelTransaction {
  final String id;
  final int amount;
  final String type;
  final String source;
  final String? description;
  final String createdAt;
  final int? balanceAfter;

  const JewelTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.source,
    this.description,
    required this.createdAt,
    this.balanceAfter,
  });

  factory JewelTransaction.fromJson(Map<String, dynamic> j) => JewelTransaction(
    id: j['id']?.toString() ?? '',
    amount: (j['amount'] ?? 0) as int,
    type: j['type'] ?? 'earn',
    source: j['source']?.toString() ?? j['type'] ?? 'unknown',
    description: j['description'] ?? j['reason'],
    createdAt: j['created_at']?.toString() ?? j['createdAt']?.toString() ?? '',
    balanceAfter: j['balance_after'] as int?,
  );
}

// ── Constants ──────────────────────────────────────────────────────────────────

const itemTypeLabels = <String, String>{
  'life_refill': 'Life Refill',
  'full_lives': 'Full Lives',
  'streak_freeze': 'Streak Freeze',
  'xp_boost': 'XP Boost',
  'double_xp': 'Double XP',
  'power_up': 'Power Up',
  'cosmetic': 'Cosmetic',
  'mystery_box': 'Mystery Box',
};

const itemTypeDescriptions = <String, String>{
  'life_refill': 'Isi ulang 1 nyawa kamu',
  'full_lives': 'Isi ulang semua nyawa kamu',
  'streak_freeze': 'Bekukan streak agar tidak hangus',
  'xp_boost': 'Tingkatkan XP yang didapat untuk sementara',
  'double_xp': 'Gandakan XP dari setiap aktivitas',
  'power_up': 'Power-up untuk membantu belajar',
  'cosmetic': 'Item kosmetik untuk tampilan',
  'mystery_box': 'Box misterius dengan hadiah acak',
};

const jewelSourceLabels = <String, String>{
  'lesson': 'Lesson',
  'quiz': 'Quiz',
  'badge': 'Badge',
  'level_up': 'Level Up',
  'event': 'Event',
  'store': 'Store',
  'admin': 'Admin',
  'mystery_box': 'Mystery Box',
};
