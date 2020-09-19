import 'package:flutter/material.dart';
import 'dart:ui';

class HoveringHeader extends StatelessWidget {
  final Widget child;
  final double offset;
  final bool visible;
  final double width;

  HoveringHeader(
      {@required this.child, this.offset = 0, this.visible = true, this.width});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: offset,
            child: Container(
              width: width ?? MediaQueryData.fromWindow(window).size.width,
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
