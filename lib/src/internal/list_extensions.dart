/// Reordering helpers for mutable lists.
extension ListExtensions<T> on List<T> {
  /// Reorders this list so that [value] becomes its first element.
  ///
  /// The list is rebuilt from two reversed runs: the elements from [value]'s
  /// position back to the start, followed by the elements after it back to the
  /// end. For example `[a, b, c, d, e]` with `c` becomes `[c, b, a, e, d]`.
  ///
  /// When [value] does not appear in the list, the list is emptied.
  List<T> sortWithTopValueAscending(T value) {
    final position = indexOf(value);
    if (position < 0) {
      clear();
      return this;
    }
    return _sortWithTopAt(position);
  }

  /// Reorders this list so that the element at [position] becomes its first
  /// element.
  ///
  /// The reordering matches [sortWithTopValueAscending]. When [position] is
  /// outside the list bounds the list is emptied.
  List<T> sortWithTopValueAtPosition(int position) {
    if (position < 0 || position >= length) {
      clear();
      return this;
    }
    return _sortWithTopAt(position);
  }

  List<T> _sortWithTopAt(int position) {
    final reordered = <T>[
      for (var index = position; index >= 0; index--) this[index],
      for (var index = length - 1; index > position; index--) this[index],
    ];
    clear();
    addAll(reordered);
    return this;
  }
}
