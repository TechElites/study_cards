/// Class to handle the deletion of multiple objects.
class ListSelector {
  final Map<int, String> _list = <int, String>{};
  bool isSelecting = false;

  /// Toggles the deletion mode.
  void toggleMode() {
    isSelecting = !isSelecting;
  }

  /// Checks if the item is in the list.
  bool isInList(int id) {
    return _list.containsKey(id);
  }

  /// Inserts the item in the list, if needed.
  void toggleItem(int id, {String name = ''}) {
    if (isSelecting) {
      if (_list.containsKey(id)) {
        _list.remove(id);
        if (_list.isEmpty) {
          isSelecting = false;
        }
      } else {
        _list[id] = name;
      }
    }
  }

  void selectAll(List<int> ids) {
    if (isSelecting) {
      for (var i = 0; i < ids.length; i++) {
        _list[ids[i]] = '';
      }
    }
  }

  /// Dumps the list and resets the deletion mode.
  Map<int, String> dumpList() {
    final list = Map<int, String>.from(_list);
    _list.clear();
    isSelecting = false;
    return list;
  }
}
