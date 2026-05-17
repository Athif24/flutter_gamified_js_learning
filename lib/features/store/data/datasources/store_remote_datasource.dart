import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint('[ACTION] Buy item: id=$itemId');
    final id = int.tryParse(itemId) ?? 0;
    try {
      await _api.post(Api.storeBuy, data: {'item_id': id, 'quantity': 1});
      debugPrint('[ACTION] Buy item ✅ id=$itemId');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gagal membeli item';
      debugPrint('[ACTION] Buy item ❌ $msg');
      throw Exception(msg);
    }
  }

  Future<void> useItem(String itemId) async {
    debugPrint('[ACTION] Use item: id=$itemId');
    final id = int.tryParse(itemId) ?? 0;
    try {
      await _api.post(Api.storeUse, data: {'item_id': id});
      debugPrint('[ACTION] Use item ✅ id=$itemId');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gagal menggunakan item';
      debugPrint('[ACTION] Use item ❌ $msg');
      throw Exception(msg);
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