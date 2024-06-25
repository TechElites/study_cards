class ListDeleter {
  final List<int> _list = [];
  bool isDeleting = false;

  void toggleMode() {
    isDeleting = !isDeleting;
  }

  bool isInList(int id) {
    return _list.contains(id);
  }

  void toggleItem(int id) {
    if (isDeleting) {
      if (_list.contains(id)) {
        _list.remove(id);
        if (_list.isEmpty) {
          isDeleting = false;
        }
      } else {
        _list.add(id);
      }
    }
  }

  List<int> dumpList() {
    final list = List<int>.from(_list);
    _list.clear();
    isDeleting = false;
    return list;
  }
}