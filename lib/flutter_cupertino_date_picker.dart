///
/// author: Dylan Wu
/// since: 2018/06/21
///
import 'package:flutter/material.dart';

import 'package:flutter_cupertino_date_picker/constants.dart';
import 'package:flutter_cupertino_date_picker/date_picker_widget.dart';

class DatePicker {
  ///
  /// Display date picker bottom sheet.
  ///
  /// cancel: Custom cancel button
  /// confirm: Custom confirm button
  ///
  static void showDatePicker(
    BuildContext context, {
    int minYear = DATE_PICKER_MIN_YEAR_DEFAULT,
    int maxYear = DATE_PICKER_MAX_YEAR_DEFAULT,
    DateTime? minDateTime,
    DateTime? maxDateTime,
    DateTime? initialDateTime,
    bool showTitleActions = true,
    Widget? cancel,
    Widget? confirm,
    VoidCallback? onCancel,
    DateValueCallback? onChanged,
    DateValueCallback? onConfirm,
    String locale = DATE_PICKER_LOCALE_DEFAULT,
    String dateFormat = DATE_PICKER_FORMAT_DEFAULT,
  }) {
    if (dateFormat.isEmpty) {
      dateFormat = DATE_PICKER_FORMAT_DEFAULT;
    }

    minDateTime ??= DateTime(minYear);
    maxDateTime ??= DateTime(maxYear);
    initialDateTime ??= DateTime.now();

    Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        minDateTime: minDateTime,
        maxDateTime: maxDateTime,
        initialDateTime: initialDateTime,
        cancel: cancel ?? const SizedBox(),
        confirm: confirm ?? const SizedBox(),
        onCancel: onCancel ?? () {},
        locale: locale,
        dateFormat: dateFormat,
        theme: Theme.of(context),
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ),
    );
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    required this.showTitleActions,
    required this.minDateTime,
    required this.maxDateTime,
    required this.initialDateTime,
    this.cancel,
    this.confirm,
    this.onChanged2,
    this.onConfirm2,
    this.onCancel,
    this.theme,
    this.barrierLabel,
    this.locale,
    this.dateFormat,
    RouteSettings? settings,
  }) : super(settings: settings);

  final bool showTitleActions;
  final DateTime minDateTime, maxDateTime, initialDateTime;
  final Widget? cancel, confirm;
  final VoidCallback? onCancel;
  final DateValueCallback? onChanged2;
  final DateValueCallback? onConfirm2;
  final ThemeData? theme;
  final String? locale;
  final String? dateFormat;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  late AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponentStateless(
        route: this,
        pickerHeight: showTitleActions
            ? DATE_PICKER_TITLE_HEIGHT + DATE_PICKER_HEIGHT
            : DATE_PICKER_HEIGHT,
      ),
    );
    bottomSheet = Theme(
      data: theme ?? Theme.of(context),
      child: bottomSheet,
    );
    return bottomSheet;
  }
}

class _DatePickerComponentStateless extends StatelessWidget {
  final _DatePickerRoute route;
  final double _pickerHeight;

  const _DatePickerComponentStateless({
    required this.route,
    required double pickerHeight,
  }) : _pickerHeight = pickerHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedBuilder(
        animation: route.animation!,
        builder: (BuildContext context, Widget? child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(route.animation!.value,
                  pickerHeight: _pickerHeight),
              child: DatePickerWidget(
                minDateTime: route.minDateTime,
                maxDateTime: route.maxDateTime,
                initDateTime: route.initialDateTime,
                dateFormat: route.dateFormat ?? DATE_PICKER_FORMAT_DEFAULT,
                showTitleActions: route.showTitleActions,
                locale: route.locale ?? 'de',
                cancel: route.cancel,
                confirm: route.confirm,
                onCancel: route.onCancel,
                onChanged2: route.onChanged2,
                onConfirm2: route.onConfirm2,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(
    this.progress, {
    this.pickerHeight,
  });

  final double progress;
  final double? pickerHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: pickerHeight ?? constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
