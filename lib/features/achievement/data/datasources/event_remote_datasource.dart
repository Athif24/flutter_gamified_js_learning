import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/event_model.dart';

class EventRemoteDatasource {
  final ApiClient _api;
  EventRemoteDatasource(this._api);

  Future<List<EventModel>> getEvents() async {
    try {
      final res = await _api.get(Api.events);
      final list = extractList(res.data);
      return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat events');
    }
  }
}
