import 'package:flutter/foundation.dart';

class NavController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void goToLibrary() => setIndex(0);
  void goToSearch() => setIndex(1);
  void goToSettings() => setIndex(2);
}

