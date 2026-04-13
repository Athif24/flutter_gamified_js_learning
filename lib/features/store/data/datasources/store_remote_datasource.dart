import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/store_model.dart';

class StoreRemoteDatasource {
  final ApiClient _api;
  StoreRemoteDatasource(this._api);

  Future<List<StoreItem>> getItems() async {
    try {
      final res  = await _api.get(Api.storeItems);
      final list = extractList(res.data);
      return list.map((e) => StoreItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat item');
    }
  }

  Future<List<InventoryItem>> getInventory() async {
    try {
      final res  = await _api.get(Api.storeInventory);
      final list = extractList(res.data);
      return list.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat inventori');
    }
  }

  Future<void> buyItem(String itemId) async {
    try {
      await _api.post(Api.storeBuy, data: {'itemId': itemId});
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal membeli item');
    }
  }

  Future<JewelBalance> getJewelBalance() async {
    try {
      final res = await _api.get(Api.jewelsBalance);
      return JewelBalance.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat saldo Jewel');
    }
  }

  Future<List<JewelTransaction>> getJewelHistory() async {
    try {
      final res  = await _api.get(Api.jewelsHistory);
      final list = extractList(res.data);
      return list.map((e) => JewelTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat riwayat Jewel');
    }
  }
}