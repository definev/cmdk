/// Scrollbar adapters and utilities for cmdk.
library;

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:cmdk/cmdk.dart';
import 'cupertino.dart';
import 'material.dart';

/// A [CommandScrollbarBuilder] that automatically selects [CupertinoScrollbar]
/// on iOS and macOS, and Material [Scrollbar] on other platforms.
CommandScrollbarBuilder adaptiveCommandScrollbarBuilder({
  bool? thumbVisibility,
  double? thickness,
  Radius? radius,
  ScrollNotificationPredicate? notificationPredicate,
}) => (BuildContext context, Widget child, ScrollController scrollController) {
  final platform = material.Theme.of(context).platform;
  final isApple =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  if (isApple) {
    return cupertinoCommandScrollbarBuilder(
      thumbVisibility: thumbVisibility,
      thickness: thickness,
      radius: radius,
      notificationPredicate: notificationPredicate,
    )(context, child, scrollController);
  } else {
    return materialCommandScrollbarBuilder(
      thumbVisibility: thumbVisibility,
      thickness: thickness,
      radius: radius,
      notificationPredicate: notificationPredicate,
    )(context, child, scrollController);
  }
};

/// A [CommandScrollbarBuilder] using Flutter's unstyled [RawScrollbar] with
/// direct styling controls.
CommandScrollbarBuilder rawCommandScrollbarBuilder({
  Color? thumbColor,
  Radius? radius,
  double? thickness,
  bool? thumbVisibility,
  double? minThumbLength,
  double? minOverscrollLength,
  Duration fadeDuration = const Duration(milliseconds: 300),
  Duration timeToFade = const Duration(milliseconds: 600),
  Duration pressDuration = Duration.zero,
  EdgeInsets? padding,
}) =>
    (BuildContext context, Widget child, ScrollController scrollController) =>
        RawScrollbar(
          controller: scrollController,
          thumbColor: thumbColor,
          radius: radius,
          thickness: thickness,
          thumbVisibility: thumbVisibility,
          minThumbLength: minThumbLength ?? 18.0,
          minOverscrollLength: minOverscrollLength,
          fadeDuration: fadeDuration,
          timeToFade: timeToFade,
          pressDuration: pressDuration,
          padding: padding,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: child,
          ),
        );
