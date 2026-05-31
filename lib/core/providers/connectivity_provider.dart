import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _connectivity = Connectivity();

final connectivityProvider = StreamProvider<bool>((ref) {
  return _connectivity.onConnectivityChanged
      .map((result) => !result.contains(ConnectivityResult.none));
});
