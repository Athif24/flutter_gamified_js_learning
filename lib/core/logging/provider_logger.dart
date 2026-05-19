import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncLoading) {
      debugPrint('[PROVIDER] ${provider.name ?? provider.runtimeType} → loading');
    } else if (newValue is AsyncError) {
      final msg = newValue.error.toString().replaceAll('\n', ' ').substring(0, newValue.error.toString().length.clamp(0, 120));
      debugPrint('[PROVIDER] ${provider.name ?? provider.runtimeType} → ❌ $msg');
    } else if (newValue is AsyncData) {
      final data = newValue.value;
      final label = data.runtimeType.toString();
      debugPrint('[PROVIDER] ${provider.name ?? provider.runtimeType} → ✅ $label');
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final msg = error.toString().replaceAll('\n', ' ').substring(0, error.toString().length.clamp(0, 120));
    debugPrint('[PROVIDER] ${provider.name ?? provider.runtimeType} → 💥 $msg');
  }
}
