import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/profile_model.dart';

final profileDsProvider = Provider((ref) =>
    ProfileRemoteDatasource(ref.read(apiClientProvider)));

final profileProvider = FutureProvider<ProfileModel>(
    (ref) => ref.read(profileDsProvider).getProfile());