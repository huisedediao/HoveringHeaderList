import 'package:flutter/material.dart';

class HoveringHeaderVM extends ChangeNotifier {
  Widget _child;
  bool _show = false;
  double _offset = 0;

  Widget get child => _child;

  set child(Widget child) {
    _child = child;
  }

  update(Widget child, double offset) {
    _child = child;
    _offset = offset;
    notifyListeners();
  }

  bool get show => _show;

  set show(bool show) {
    _show = show;
    notifyListeners();
  }

  double get offset => _offset;
}
