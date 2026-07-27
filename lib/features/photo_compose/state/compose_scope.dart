import 'package:flutter/material.dart';

import 'compose_controller.dart';

/// Makes the [ComposeController] available to the composer's widget tree, and
/// rebuilds dependents whenever it changes.
///
/// The controller is owned above the tool switcher, so a user can wander off to
/// another tool or the licence page and come back to find their sheet exactly
/// as they left it.
class ComposeScope extends InheritedNotifier<ComposeController> {
  const ComposeScope({super.key, required ComposeController controller, required super.child})
    : super(notifier: controller);

  static ComposeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ComposeScope>();
    assert(scope != null, 'No ComposeScope found above this widget');
    return scope!.notifier!;
  }

  /// Reads the controller without subscribing to its changes.
  static ComposeController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ComposeScope>();
    assert(scope != null, 'No ComposeScope found above this widget');
    return scope!.notifier!;
  }
}

/// Owns a [ComposeController] for the lifetime of the app.
class ComposeScopeHost extends StatefulWidget {
  const ComposeScopeHost({super.key, required this.child});

  final Widget child;

  @override
  State<ComposeScopeHost> createState() => _ComposeScopeHostState();
}

class _ComposeScopeHostState extends State<ComposeScopeHost> {
  final ComposeController _controller = ComposeController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ComposeScope(controller: _controller, child: widget.child);
}
