import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/reward_pool_remote_datasource.dart';
import '../../data/models/reward_pool_model.dart';

final rewardPoolDsProvider = Provider(
  (ref) => RewardPoolRemoteDatasource(ref.read(apiClientProvider)),
);

final rewardPoolsProvider = FutureProvider<List<RewardPool>>(
  (ref) => ref.read(rewardPoolDsProvider).getPools('mystery_box'),
);

