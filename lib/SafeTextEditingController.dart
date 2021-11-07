import 'package:flutter/material.dart';

/// A [TextEditingController] that can be disposed of when the parent is disposed
class SafeTextEditingController extends TextEditingController
    implements AutoDisposable {
  SafeTextEditingController register(SafeDisposableHost host) {
    host._allDisposables.add(this);
    return this;
  }
}

/// A [FocusNode] that can be disposed of when the parent is disposed
class SafeFocusNode extends FocusNode implements AutoDisposable {
  SafeFocusNode register(SafeDisposableHost host) {
    host._allDisposables.add(this);
    return this;
  }
}

/// Wraps anything that can be disposed of. Probably very unsafe
class UnsafeAutoDisposableWrapper extends AutoDisposable {
  UnsafeAutoDisposableWrapper(this.wrapped);
  final dynamic wrapped;

  UnsafeAutoDisposableWrapper register(SafeDisposableHost host) {
    host._allDisposables.add(this);
    return this;
  }

  @override
  void dispose() {
    wrapped.dispose();
  }
}

abstract class AutoDisposable extends SafeDisposable {
  AutoDisposable register(SafeDisposableHost host) {
    host._allDisposables.add(this);
    return this;
  }
}

/// Something that can be disposed
abstract class SafeDisposable {
  void dispose();
}

/// A host that will unregister all [SafeDisposable]s associated with it when it is disposed/killed
abstract class SafeDisposableHost {
  List<SafeDisposable> _allDisposables = List.empty(growable: true);

  void unregisterAllDisposables() {
    _allDisposables.forEach((disposable) {
      disposable.dispose();
    });
  }
}

/// A State that disposes of all registered Disposables when it is disposed
abstract class DisposableHostState<T extends StatefulWidget> extends State<T>
    implements SafeDisposableHost {
  List<SafeDisposable> _allDisposables = List.empty(growable: true);
  @override
  void dispose() {
    unregisterAllDisposables();
    super.dispose();
  }

  @override
  void unregisterAllDisposables() {
    _allDisposables.forEach((disposable) {
      disposable.dispose();
    });
  }
}
