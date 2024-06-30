/// Class to handle the deletion of multiple objects.
class ListDeleter {
  final Map<int, String> _list = <int, String>{};
  bool isDeleting = false;

  /// Toggles the deletion mode.
  void toggleMode() {
    isDeleting = !isDeleting;
  }

  /// Checks if the item is in the list.
  bool isInList(int id) {
    return _list.containsKey(id);
  }

  /// Inserts the item in the list, if needed.
  void toggleItem(int id, {String name = ''}) {
    if (isDeleting) {
      if (_list.containsKey(id)) {
        _list.remove(id);
        if (_list.isEmpty) {
          isDeleting = false;
        }
      } else {
        _list[id] = name;
      }
    }
  }

  /// Dumps the list and resets the deletion mode.
  Map<int, String> dumpList() {
    final list = Map<int, String>.from(_list);
    _list.clear();
    isDeleting = false;
    return list;
  }
}
