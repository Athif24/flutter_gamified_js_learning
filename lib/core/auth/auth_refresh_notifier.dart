import 'package:flutter/foundation.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final authRefreshNotifierProvider = Provider<AuthRefreshNotifier>((ref) {
  final notifier = AuthRefreshNotifier();
  ref.listen<AuthState>(authProvider, (_, __) {
    notifier.notify();
  });
  return notifier;
});
