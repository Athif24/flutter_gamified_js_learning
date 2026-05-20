import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cacheDuration = Duration(seconds: 15);

enum FetchStatus { idle, fetching, success, error }

class FetchState {
  final FetchStatus status;
  final DateTime? lastFetchedAt;
  final String? error;

  const FetchState({
    this.status = FetchStatus.idle,
    this.lastFetchedAt,
    this.error,
  });

  bool get shouldRefresh =>
      status == FetchStatus.idle ||
      status == FetchStatus.error ||
      lastFetchedAt == null ||
      DateTime.now().difference(lastFetchedAt!) > _cacheDuration;

  bool get isFetching => status == FetchStatus.fetching;
  bool get isSuccess => status == FetchStatus.success;

  FetchState copyWith({
    FetchStatus? status,
    DateTime? lastFetchedAt,
    String? error,
  }) =>
      FetchState(
        status: status ?? this.status,
        lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
        error: error ?? this.error,
      );
}

class FetchStateNotifier extends StateNotifier<FetchState> {
  FetchStateNotifier() : super(const FetchState());

  void markFetching() {
    state = state.copyWith(
      status: FetchStatus.fetching,
      error: null,
    );
  }

  void markSuccess() {
    state = state.copyWith(
      status: FetchStatus.success,
      lastFetchedAt: DateTime.now(),
      error: null,
    );
  }

  void markError(String error) {
    state = state.copyWith(
      status: FetchStatus.error,
      lastFetchedAt: DateTime.now(),
      error: error,
    );
  }

  void reset() {
    state = const FetchState();
  }

  bool get shouldRefresh => state.shouldRefresh;
  bool get isFetching => state.isFetching;
}
