import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int _hadithIndex = 0;

  int get selectedIndex => _selectedIndex;
  int get hadithIndex => _hadithIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void rotateHadith(int totalAhadith) {
    _hadithIndex = DateTime.now().day % totalAhadith;
    notifyListeners();
  }
}
