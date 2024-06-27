class ListDeleter {
  final Map<int, String> _list = <int, String>{};
  bool isDeleting = false;

  void toggleMode() {
    isDeleting = !isDeleting;
  }

  bool isInList(int id) {
    return _list.containsKey(id);
  }

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

  Map<int, String> dumpList() {
    final list = Map<int, String>.from(_list);
    _list.clear();
    isDeleting = false;
    return list;
  }
}
