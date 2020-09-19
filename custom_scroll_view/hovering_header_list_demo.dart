import 'package:flutter/material.dart';
import 'hovering_header_list.dart';
import 'dart:ui';

class HoveringHeaderListDemo extends StatefulWidget {
  @override
  _HoveringHeaderListDemoState createState() => _HoveringHeaderListDemoState();
}

class _HoveringHeaderListDemoState extends State<HoveringHeaderListDemo> {
  GlobalKey<HoveringHeaderListState> _globalKey = GlobalKey();

  @override
  Widget build(ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hover_header_list"),
      ),
      body: HoveringHeaderList(
        key: _globalKey,

        ///分组信息，每组有几个item
        itemCounts: List.generate(5, (index) => 5),

        ///header builder
        sectionHeaderBuild: (ctx, section) {
          if (section % 2 == 0) {
            return Header(
              "我是第一种段头 $section",
            );
          } else {
            return Header2(
              "我是第二种段头 $section",
            );
          }
        },

        ///header高度
        headerHeightForSection: (section) {
          if(section % 2 == 0) {
            return Header.height;
          } else {
            return Header2.height;
          }
        },

        ///item builder
        itemBuilder: (ctx, indexPath, height) {
          if (indexPath.index % 2 == 0) {
            return CellOne("我是第一种cell $indexPath", () {
              _globalKey.currentState.animateToIndexPath(SectionIndexPath(2, 3),
                  duration: Duration(seconds: 1), curve: Curves.ease);
            });
          } else {
            return CellTwo("我是第二种cell $indexPath", () {
              _globalKey.currentState.animateToIndexPath(SectionIndexPath(3, 2),
                  duration: Duration(seconds: 1), curve: Curves.ease);
            });
          }
        },

        ///item高度
        itemHeightForIndexPath: (indexPath) {
          if (indexPath.index % 2 == 0) {
            return CellOne.height;
          } else {
            return CellTwo.height;
          }
        },

        ///分割线builder
        separatorBuilder: (ctx, indexPath, height, isLast) {
//        print("indexPath : $indexPath,$isLast");
          return Separator();
        },

        ///分割线高度
        separatorHeightForIndexPath: (indexPath, isLast) {
          return Separator.height;
        },

        ///滚动到底部和离开底部的回调
        onEndChanged: (end) {
          print("end : $end");
        },

        ///offset改变回调
        offsetChanged: (offset) {
//        print("111111:offset : $offset");
        },

        ///滚动到顶部和离开顶部的回调
        onTopChanged: (top) {
          print("top:$top");
        },

        ///是否需要悬停header
        hover: true,
      ),
    );
  }
}

class CellOne extends StatelessWidget {
  static final height = 44.0;
  final String title;
  final VoidCallback onPressed;

  CellOne(this.title, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        color: Colors.black38,
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class CellTwo extends StatelessWidget {
  static final height = 88.0;
  final String title;
  final VoidCallback onPressed;

  CellTwo(this.title, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        color: Colors.black54,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class Separator extends StatelessWidget {
  static final height = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.white,
    );
  }
}

class Header extends StatelessWidget {
  static final height = 50.0;
  final String title;
  final Color color;

  Header(this.title, {this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(-0.8, 0.0),
      height: height,
      color: color ?? Colors.orange,
      child: Text(
        title,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}

class Header2 extends StatelessWidget {
  static final height = 80.0;
  final String title;
  final Color color;

  Header2(this.title, {this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(-0.8, 0.0),
      height: height,
      color: color ?? Colors.green,
      child: Text(
        title,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}