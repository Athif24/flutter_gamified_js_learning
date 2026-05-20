import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/fetch_state_notifier.dart';

final courseListFetchProvider =
    StateNotifierProvider<FetchStateNotifier, FetchState>(
        (_) => FetchStateNotifier());

final lessonFetchProvider =
    StateNotifierProvider<FetchStateNotifier, FetchState>(
        (_) => FetchStateNotifier());

final quizIntroFetchProvider =
    StateNotifierProvider<FetchStateNotifier, FetchState>(
        (_) => FetchStateNotifier());

final achievementFetchProvider =
    StateNotifierProvider<FetchStateNotifier, FetchState>(
        (_) => FetchStateNotifier());

final leaderboardFetchProvider =
    StateNotifierProvider<FetchStateNotifier, FetchState>(
        (_) => FetchStateNotifier());

final storeFetchProvider =
    StateNotifierProvider<FetchStateNotifier, FetchState>(
        (_) => FetchStateNotifier());

final profileFetchProvider =
    StateNotifierProvider<FetchStateNotifier, FetchState>(
        (_) => FetchStateNotifier());
