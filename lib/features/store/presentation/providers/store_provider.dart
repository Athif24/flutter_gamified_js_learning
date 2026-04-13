import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/store_remote_datasource.dart';
import '../../data/models/store_model.dart';

final storeDsProvider = Provider((ref) =>
    StoreRemoteDatasource(ref.read(apiClientProvider)));

final storeItemsProvider = FutureProvider<List<StoreItem>>(
    (ref) => ref.read(storeDsProvider).getItems());

final inventoryProvider = FutureProvider<List<InventoryItem>>(
    (ref) => ref.read(storeDsProvider).getInventory());

final jewelBalanceProvider = FutureProvider<JewelBalance>(
    (ref) => ref.read(storeDsProvider).getJewelBalance());

final jewelHistoryProvider = FutureProvider<List<JewelTransaction>>(
    (ref) => ref.read(storeDsProvider).getJewelHistory());

// Store tab selection
final storeTabProvider = StateProvider<int>((_) => 0);