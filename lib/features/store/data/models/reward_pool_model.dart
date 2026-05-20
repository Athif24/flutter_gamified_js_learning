import 'store_model.dart';

class RewardPool {
  final int id;
  final String name;
  final String poolType;
  final String? color;
  final String? badgeLabel;
  final String? icon;
  final int jewelCost;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final List<PoolReward> rewards;

  const RewardPool({
    required this.id,
    required this.name,
    required this.poolType,
    this.color,
    this.badgeLabel,
    this.icon,
    required this.jewelCost,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.rewards,
  });

  factory RewardPool.fromJson(Map<String, dynamic> j) => RewardPool(
        id: (j['id'] ?? 0) as int,
        name: j['name'] ?? '',
        poolType: j['pool_type'] ?? 'mystery_box',
        color: j['color'],
        badgeLabel: j['badge_label'],
        icon: j['icon'],
        jewelCost: (j['jewel_cost'] ?? 0) as int,
        isActive: j['is_active'] ?? true,
        createdAt: j['created_at'],
        updatedAt: j['updated_at'],
        rewards: (j['rewards'] as List<dynamic>?)
                ?.map((r) => PoolReward.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class PoolReward {
  final int id;
  final int poolId;
  final String rewardType;
  final int? rewardItemId;
  final int minAmount;
  final int maxAmount;
  final double probability;
  final String displayLabel;
  final String? color;
  final StoreItem? rewardItem;

  const PoolReward({
    required this.id,
    required this.poolId,
    required this.rewardType,
    this.rewardItemId,
    required this.minAmount,
    required this.maxAmount,
    required this.probability,
    required this.displayLabel,
    this.color,
    this.rewardItem,
  });

  factory PoolReward.fromJson(Map<String, dynamic> j) => PoolReward(
        id: (j['id'] ?? 0) as int,
        poolId: (j['pool_id'] ?? 0) as int,
        rewardType: j['reward_type'] ?? 'jewels',
        rewardItemId: j['reward_item_id'] as int?,
        minAmount: (j['min_amount'] ?? 0) as int,
        maxAmount: (j['max_amount'] ?? 0) as int,
        probability: (j['probability'] ?? 0.0) as double,
        displayLabel: j['display_label'] ?? '',
        color: j['color'],
        rewardItem: j['reward_item'] != null
            ? StoreItem.fromJson(j['reward_item'] as Map<String, dynamic>)
            : null,
      );

  int get percentage => (probability * 100).round();
}

class MysteryBoxResult {
  final String message;
  final String rewardType;
  final int amount;
  final String displayLabel;
  final int? itemId;
  final String? itemName;
  final String? itemIcon;

  const MysteryBoxResult({
    required this.message,
    required this.rewardType,
    required this.amount,
    required this.displayLabel,
    this.itemId,
    this.itemName,
    this.itemIcon,
  });

  factory MysteryBoxResult.fromJson(Map<String, dynamic> j) {
    final reward = j['reward'] ?? j;
    return MysteryBoxResult(
      message: j['message'] ?? '',
      rewardType: reward['type'] ?? 'jewels',
      amount: (reward['amount'] ?? 0) as int,
      displayLabel: reward['display_label'] ?? '',
      itemId: reward['item_id'] as int?,
      itemName: reward['item_name'],
      itemIcon: reward['item_icon'],
    );
  }

  bool get isGoodReward {
    return (rewardType == 'xp' && amount >= 500) ||
        (rewardType == 'jewels' && amount >= 400) ||
        rewardType == 'item';
  }

  String get rewardLabel {
    switch (rewardType) {
      case 'xp':
        return 'XP';
      case 'jewels':
        return 'Jewel';
      case 'item':
        return 'Item';
      default:
        return rewardType;
    }
  }
}
