import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/profile_model.dart';

final profileDsProvider = Provider((ref) =>
    ProfileRemoteDatasource(ref.read(apiClientProvider)));

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isLoggedIn) throw Exception('Not authenticated');
  return ref.read(profileDsProvider).getProfile();
});