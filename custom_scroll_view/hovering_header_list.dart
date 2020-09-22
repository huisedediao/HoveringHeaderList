import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'section_list.dart';
import 'custom_scroll_view_config.dart';
import 'hovering_header.dart';
import 'hovering_header_vm.dart';
import 'hovering_offset_info.dart';
export 'custom_scroll_view_config.dart';

class HoveringHeaderList extends StatefulWidget {
  final List<int> itemCounts;
  final HeaderBuilder sectionHeaderBuild;
  final HoverHeaderListItemBuilder itemBuilder;
  final HoverHeaderListSeparatorBuilder separatorBuilder;
  final ValueChanged onTopChanged;
  final ValueChanged onEndChanged;
  final SectionListOffsetChanged onOffsetChanged;
  final double initialScrollOffset;
  final ItemHeightForIndexPath itemHeightForIndexPath;
  final SeparatorHeightForIndexPath separatorHeightForIndexPath;
  final HeaderHeightForSection headerHeightForSection;
  final bool hover;
  final bool needSafeArea;

  HoveringHeaderList(
      {@required this.itemCounts,
      @required this.sectionHeaderBuild,
      @required this.itemBuilder,
      @required this.itemHeightForIndexPath,
      @required this.headerHeightForSection,
      this.separatorHeightForIndexPath,
      this.separatorBuilder,
      this.onTopChanged,
      this.onEndChanged,
      this.onOffsetChanged,
      this.initialScrollOffset = 0,
      this.hover = true,
      this.needSafeArea = false,
      Key key})
      : assert(
            (separatorHeightForIndexPath == null && separatorBuilder == null) ||
                (separatorBuilder != null &&
                    separatorHeightForIndexPath != null),
            "separatorHeightForIndexPath 和 separatorBuilder必须同时为null或者同时不为null"),
        assert(itemBuilder != null, "itemBuilder must not be null"),
        assert(itemHeightForIndexPath != null,
            "itemHeightForIndexPath  must not be null"),
        assert(
            sectionHeaderBuild != null, "sectionHeaderBuild  must not be null"),
        assert(headerHeightForSection != null,
            "headerHeightForSection  must not be null"),
        super(key: key);

  @override
  HoveringHeaderListState createState() => HoveringHeaderListState();
}

class HoveringHeaderListState extends State<HoveringHeaderList> {
  double _lastOffset = 0;
  int _hoverOffsetInfoIndex = 0;
  GlobalKey<SectionListState> _sectionListKey = GlobalKey();

  ///用于控制hoverHeader偏移量和是否显示
  HoveringHeaderVM _hoverVM;

  ///section : HoverOffsetInfo
  Map<int, HoveringOffsetInfo> _hoverOffsetInfoMap;

  ///清除已经缓存的高度信息，在下拉刷新时使用
  clean() {
    _hoverOffsetInfoMap = {};
  }

  jumpTo(double offset) {
    _sectionListKey.currentState.jumpTo(offset);
  }

  jumpToIndexPath(SectionIndexPath indexPath) {
    if (_isValidIndexPath(indexPath)) {
      double offset = _computeJumpIndexPathOffset(indexPath);
      jumpTo(offset);
    }
  }

  animateTo(
    double offset, {
    @required Duration duration,
    @required Curve curve,
  }) {
    _sectionListKey.currentState
        .animateTo(offset, duration: duration, curve: curve);
  }

  animateToIndexPath(
    SectionIndexPath indexPath, {
    @required Duration duration,
    @required Curve curve,
  }) {
    if (_isValidIndexPath(indexPath)) {
      double offset = _computeJumpIndexPathOffset(indexPath);
      animateTo(offset, duration: duration, curve: curve);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.hover) {
      _hoverVM = HoveringHeaderVM();
      _hoverOffsetInfoMap = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hover) {
      return Stack(
        children: <Widget>[
          _buildSectionList(),
          ChangeNotifierProvider(create: (ctx) {
            return _hoverVM;
          }, child: Consumer(
            builder: (ctx, HoveringHeaderVM hoverVM, child) {
              return HoveringHeader(
                child: hoverVM.child,
                offset: hoverVM.offset,
                visible: hoverVM.show,
              );
            },
          ))
        ],
      );
    } else {
      return _buildSectionList();
    }
  }

  _buildSectionList() {
    return SectionList(
      itemCounts: widget.itemCounts,
      sectionHeaderBuilder: _sectionHeaderBuilder,
      itemBuilder: _itemBuilder,
      separatorBuilder: _separatorBuilder,
      onTopChanged: widget.onTopChanged,
      onEndChanged: widget.onEndChanged,
      onOffsetChanged: _handleOffset,
      initialScrollOffset: widget.initialScrollOffset,
      needSafeArea: widget.needSafeArea,
      key: _sectionListKey,
    );
  }

//  _buildSection

  Widget _sectionHeaderBuilder(ctx, section) {
    //            print("sectionHeaderBuild : $section");
    double headerH = widget.headerHeightForSection(section);

    Widget ret = Container(
      height: headerH,
      child: widget.sectionHeaderBuild(ctx, section),
    );

    if (widget.hover) {
      HoveringOffsetInfo info = _hoverOffsetInfoFor(section);
      info.headerHeight = headerH;
      info.header = ret;
      if (_hoverVM.child == null && section == 0) {
        _hoverVM.child = info.header;
      }
    }
    return ret;
  }

  Widget _itemBuilder(ctx, indexPath) {
//            print("itemBuilder : $indexPath");
    double itemH = widget.itemHeightForIndexPath(indexPath);
    if (widget.hover) {
      HoveringOffsetInfo info = _hoverOffsetInfoFor(indexPath.section);
      info.addItemHeight(itemH, indexPath.index);
    }
    return Container(
      height: itemH,
      child: widget.itemBuilder(ctx, indexPath, itemH),
    );
  }

  Widget _separatorBuilder(ctx, indexPath, isLast) {
    if (widget.separatorBuilder == null) {
      return Container();
    }
    double separatorH = widget.separatorHeightForIndexPath(indexPath, isLast);
    if (widget.hover) {
      HoveringOffsetInfo info = _hoverOffsetInfoFor(indexPath.section);
      info.addSeparatorHeight(separatorH, indexPath.index);
    }
    return Container(
      height: separatorH,
      child: widget.separatorBuilder(ctx, indexPath, separatorH, isLast),
    );
  }

  _handleOffset(offset, maxOffset) {
    if (widget.onOffsetChanged != null) {
      widget.onOffsetChanged(offset, maxOffset);
    }

    if (widget.hover == false) return;
    //            print("offsetChanged : $offset");
    bool show = offset >= 0;
    if (_hoverVM.show != show) {
      _hoverVM.show = show;
    }

    //是否向上滚动
    bool upward = offset - _lastOffset > 0;
    _lastOffset = offset;

    HoveringOffsetInfo offsetInfo;

    if (_hoverOffsetInfoMap.length > _hoverOffsetInfoIndex) {
      offsetInfo = _hoverOffsetInfoMap[_hoverOffsetInfoIndex];
//              print(
//                  "start offset:${offsetInfo.startOffset},end offset:${offsetInfo.endOffset},_hoverOffsetInfoIndex:$_hoverOffsetInfoIndex");
      if (upward) {
        ///向上滚动
        if (offset < offsetInfo.startOffset) {
          /// [sectionStartOffset,startOffset)
          if (_hoverVM.offset != 0) {
            _hoverVM.update(offsetInfo.header, 0);
          }
        } else if (offset > offsetInfo.endOffset) {
          ///(endOffset
          ///超过endOffset，切换到下一个offsetInfo
          _hoverOffsetInfoIndex++;
          if (_hoverOffsetInfoIndex >= _hoverOffsetInfoMap.length) {
            _hoverOffsetInfoIndex = _hoverOffsetInfoMap.length - 1;
          }
          HoveringOffsetInfo nextInfo =
              _hoverOffsetInfoMap[_hoverOffsetInfoIndex];
          _hoverVM.update(nextInfo.header, 0);
        } else {
          /// [startOffset,endOffset]
          _hoverVM.update(offsetInfo.header, offsetInfo.startOffset - offset);
        }
      } else {
        ///向下滚动
        if (offset >= offsetInfo.startOffset) {
          ///[startOffset,endOffset]
          _hoverVM.update(offsetInfo.header, offsetInfo.startOffset - offset);
        } else if (offset >= offsetInfo.sectionStartOffset) {
          ///[sectionStartOffset,startOffset）
          if (_hoverVM.offset != 0) {
            _hoverVM.update(offsetInfo.header, 0);
          }
        } else {
          /// sectionStartOffset)
          /// 切换到上一个offsetInfo
          ///其实就是offset小于上一个offsetInfo的endOffset的情况
          _hoverOffsetInfoIndex--;
          if (_hoverOffsetInfoIndex < 0) {
            _hoverOffsetInfoIndex = 0;
          }
          HoveringOffsetInfo prevInfo =
              _hoverOffsetInfoMap[_hoverOffsetInfoIndex];
          _hoverVM.update(prevInfo.header, prevInfo.startOffset - offset);
        }
      }
    }
  }

  HoveringOffsetInfo _hoverOffsetInfoFor(int section) {
    HoveringOffsetInfo info = _hoverOffsetInfoMap[section];
    if (info == null) {
      HoveringOffsetInfo prevInfo = _hoverOffsetInfoMap[section - 1];
      if (prevInfo != null) {
        info = HoveringOffsetInfo(prevInfo.endOffset);
      } else {
        info = HoveringOffsetInfo(0);
      }
      _hoverOffsetInfoMap[section] = info;
    }
    return info;
  }

  bool _isValidIndexPath(SectionIndexPath indexPath) {
    if (indexPath == null) return false;
    int section = indexPath.section;
    if (section >= widget.itemCounts.length ||
        indexPath.index >= widget.itemCounts[section]) return false;
    return true;
  }

  _computeJumpIndexPathOffset(SectionIndexPath indexPath) {
    int section = indexPath.section;
    double offset = 0;
    for (var i = 0; i <= section; i++) {
      if (widget.hover == false || i != section) {
        double headerH = widget.headerHeightForSection(i);
        offset += headerH;
//        print("section:$section,headerH:$headerH");
      }
      int counts = widget.itemCounts[i];
      int itemCount;
      if (i == section) {
        itemCount = indexPath.index + 1;
      } else {
        itemCount = counts;
      }
      for (var j = 0; j < itemCount; j++) {
        if (j == itemCount - 1 && i == section) {
        } else {
          SectionIndexPath tempIndexPath = SectionIndexPath(i, j);
          double itemH = widget.itemHeightForIndexPath(tempIndexPath);
          double separatorH = 0;
          if (widget.separatorHeightForIndexPath != null) {
            separatorH = widget.separatorHeightForIndexPath(
                tempIndexPath, j == counts - 1);
          }
//          print("indexPath:$tempIndexPath,itemH:$itemH,separatorH:$separatorH");
          offset += itemH + separatorH;
        }
      }
    }
//    print("_computeJumpIndexPathOffset : $offset");
    return offset;
  }
}
