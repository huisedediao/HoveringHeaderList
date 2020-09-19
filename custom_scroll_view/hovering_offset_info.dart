import 'package:flutter/material.dart';

class HoveringOffsetInfo {
  final double sectionStartOffset;
  Widget _header;
  double _headerH = 0;

  ///不包括header高度
  ///所有item 和 separator的高度
  double _totalContentH = 0;

  ///是否记录过header的高度
  bool _recordedHeaderH = false;

  ///是否已经拷贝过header
  bool _copyedHeader = false;

  ///item的高度记录到哪一个index了
  int _itemIndex = -1;

  ///separator的高度记录到哪一个index了
  int _separatorIndex = -1;

  HoveringOffsetInfo(this.sectionStartOffset);

  Widget get header => _header;

  set header(Widget header) {
    if (_copyedHeader) return;
    _header = header;
    _copyedHeader = true;
  }

  set headerHeight(double headerH) {
    ///如果已经记录过了
    if (_recordedHeaderH) return;
    _headerH = headerH;
    _recordedHeaderH = true;
  }

  bool get recordedHeader => _recordedHeaderH;

  int get itemIndex => _itemIndex;

  int get separatorIndex => _separatorIndex;

  double get startOffset => _totalContentH + sectionStartOffset;

  double get endOffset => startOffset + _headerH;

  addItemHeight(double itemHeight, int index) {
    ///如果已经记录过了
    if (_itemIndex >= index) return;
    _totalContentH += itemHeight;
    _itemIndex = index;
  }

  addSeparatorHeight(double separatorHeight, int index) {
    ///如果已经记录过了
    if (_separatorIndex >= index) return;
    _totalContentH += separatorHeight;
    _separatorIndex = index;
  }
}