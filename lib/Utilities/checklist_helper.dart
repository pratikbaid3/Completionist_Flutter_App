class ChecklistManager {
  ChecklistManager({this.noOfElements});
  final noOfElements;
  List<bool> isSwitcher = new List();

  void buildList() {
    for (int i = 0; i < noOfElements; i++) {
      isSwitcher.add(false);
    }
  }
}
