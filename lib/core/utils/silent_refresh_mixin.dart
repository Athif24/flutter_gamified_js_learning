import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './fetch_state_notifier.dart';

mixin SilentRefreshMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Timer? _slowIndicatorTimer;
  bool _showSlowIndicator = false;

  bool get showSlowIndicator => _showSlowIndicator;

  void setShowSlowIndicator(bool value) {
    if (mounted) {
      setState(() => _showSlowIndicator = value);
    }
  }

  Future<R> silentFetch<R>({
    required Future<R> Function() fetch,
    required FetchStateNotifier fetchState,
    Duration slowThreshold = const Duration(milliseconds: 500),
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    if (!fetchState.shouldRefresh) return await fetch();

    fetchState.markFetching();
    _showSlowIndicator = false;

    _slowIndicatorTimer = Timer(slowThreshold, () {
      if (fetchState.isFetching) {
        setShowSlowIndicator(true);
      }
    });

    try {
      final result = await fetch();
      _slowIndicatorTimer?.cancel();
      if (mounted) {
        fetchState.markSuccess();
        setShowSlowIndicator(false);
        onSuccess?.call();
      }
      return result;
    } catch (e) {
      _slowIndicatorTimer?.cancel();
      if (mounted) {
        fetchState.markError(e.toString());
        setShowSlowIndicator(false);
        onError?.call(e.toString());
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _slowIndicatorTimer?.cancel();
    super.dispose();
  }
}
