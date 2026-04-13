import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/leaderboard_remote_datasource.dart';
import '../../data/models/leaderboard_model.dart';

final leaderboardDsProvider = Provider((ref) =>
    LeaderboardRemoteDatasource(ref.read(apiClientProvider)));

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>(
    (ref) => ref.read(leaderboardDsProvider).getLeaderboard());