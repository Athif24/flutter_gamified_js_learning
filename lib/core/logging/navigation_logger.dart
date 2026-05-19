import 'package:flutter/material.dart';

class NavigationLogger extends NavigatorObserver {
  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    final name = route.settings.name ?? route.settings.toString();
    final loc = (route.settings.arguments != null)
        ? '$name (${route.settings.arguments})'
        : name;
    debugPrint('[NAV] → $loc');
  }

  @override
  void didPop(Route<Object?> route, Route<Object?>? previousRoute) {
    final name = route.settings.name ?? route.settings.toString();
    debugPrint('[NAV] ← $name');
  }

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) {
    final newName = newRoute?.settings.name ?? newRoute?.settings.toString() ?? '?';
    final oldName = oldRoute?.settings.name ?? oldRoute?.settings.toString() ?? '?';
    debugPrint('[NAV] ⇄ $oldName → $newName');
  }

  @override
  void didRemove(Route<Object?> route, Route<Object?>? previousRoute) {
    final name = route.settings.name ?? route.settings.toString();
    debugPrint('[NAV] ✕ $name removed');
  }
}
