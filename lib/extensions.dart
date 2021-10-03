extension IterableExtensions<T> on Iterable<T> {

  /// Returns the first element or null
  /// mostly for completeness, not sure it has any real use
  T? firstOrNull() {
    if(this.isEmpty) {
      return null;
    }
    return this.first;
  }

  /// Returns the first matching element or null
  T? firstWhereOrNull(bool test(T element)) {
    if(this.isEmpty) {
      return null;
    }
    var didntFindElement = false;
    var returnValue =  this.firstWhere(test, orElse: () {
        didntFindElement = true;
        return this.first;
    }
    );
    return didntFindElement ? null : returnValue;
  }
}
