import 'package:flutter/material.dart';
import 'section_index_path.dart';
export 'section_index_path.dart';

typedef HeaderBuilder = Widget Function(
    BuildContext context, int section);
typedef HoverHeaderListItemBuilder = Widget Function(
    BuildContext context, SectionIndexPath indexPath, double height);
typedef SectionListItemBuilder = Widget Function(
    BuildContext context, SectionIndexPath indexPath);
typedef HoverHeaderListSeparatorBuilder = Widget Function(BuildContext context,
    SectionIndexPath indexPath, double height, bool isLast);
typedef SectionListSeparatorBuilder = Widget Function(
    BuildContext context, SectionIndexPath indexPath, bool isLast);
typedef HoverHeaderBuilder = Widget Function(
    BuildContext context, double offset, Widget child, bool visible);
typedef HeaderHeightForSection = double Function(int section);
typedef ItemHeightForIndexPath = double Function(SectionIndexPath indexPath);
typedef SeparatorHeightForIndexPath = double Function(
    SectionIndexPath indexPath, bool isLast);
typedef SectionListOffsetChanged = void Function(
    double currentOffset, double maxOffset);
