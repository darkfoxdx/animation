import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../utis/extension.dart';

class Cube extends StatefulWidget {
  final List<Widget> children;
  final int startingIndex;
  final double contentWidth;
  final double contentHeight;
  final Function(int) onPageChanged;

  Cube({
    Key key,
    @required this.children,
    this.startingIndex,
    @required this.contentWidth,
    this.contentHeight,
    this.onPageChanged,
  }) : super(key: key);

  @override
  _CubeState createState() => _CubeState();
}

class _CubeState extends State<Cube> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool _canBeDragged = false;
  double delta = 0;

  // final double maxSlide = 300.0;

  var index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.startingIndex ?? 0;
    animationController = AnimationController(
      lowerBound: -1.0,
      upperBound: 1.0,
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  int calcPrevious(int index) {
    var newIndex = index - 1;
    if (newIndex < 0) {
      newIndex = widget.children.length - 1;
    }
    return newIndex;
  }

  int calcNext(int index) {
    var newIndex = index + 1;
    if (newIndex >= widget.children.length) {
      newIndex = 0;
    }
    return newIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            var maxSlide = widget.contentWidth;
            var defaultOffset = Offset(maxSlide, 0);
            var defaultRotation = math.pi / 2;
            var previous = calcPrevious(index);
            var next = calcNext(index);
            var mainOffset = Offset(maxSlide * (animationController.value), 0);
            var mainRotateY = math.pi / 2 * -animationController.value;

            Offset leftOffset = defaultOffset;
            double leftRotateY = defaultRotation;
            var leftToCenter = ui.lerpDouble(-1, 0, animationController.value);
            if (leftToCenter > -1) {
              leftOffset = Offset(maxSlide * (leftToCenter), 0);
              leftRotateY = math.pi / 2 * -leftToCenter;
            }

            Offset rightOffset = defaultOffset;
            double rightRotateY = defaultRotation;
            var rightToCenter = ui.lerpDouble(1, 0, -animationController.value);
            if (rightToCenter < 1) {
              rightOffset = Offset(maxSlide * (rightToCenter), 0);
              rightRotateY = math.pi / 2 * -rightToCenter;
            }

            return Stack(
              children: widget.children.mapIndexed((e, i) {
                var alignment = FractionalOffset.center;
                var offset = defaultOffset;
                var rotation = defaultRotation;

                if (i == previous) {
                  alignment = FractionalOffset.centerRight;
                  offset = leftOffset;
                  rotation = leftRotateY;
                } else if (i == next) {
                  alignment = FractionalOffset.centerLeft;
                  offset = rightOffset;
                  rotation = rightRotateY;
                } else if (i == index) {
                  alignment = animationController.value < 0
                      ? FractionalOffset.centerRight
                      : FractionalOffset.centerLeft;
                  offset = mainOffset;
                  rotation = mainRotateY;
                }

                return Container(
                  width: widget.contentWidth,
                  height: widget.contentHeight,
                  child: Transform.translate(
                    offset: offset,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(rotation),
                      alignment: alignment,
                      child: e,
                    ),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _canBeDragged = animationController.value == 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / widget.contentWidth;
      animationController.value += delta;
    }
  }

  void _moveBack() {
    index = calcNext(index);
    animationController.value = 0;
    widget.onPageChanged?.call(index);
  }

  void _moveForward() {
    index = calcPrevious(index);
    animationController.value = 0;
    widget.onPageChanged?.call(index);
  }

  void _onDragEnd(DragEndDetails details) {
    double _kMinFlingVelocity = 365.0;

    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }

    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      animationController.fling(velocity: visualVelocity).whenComplete(() {
        if (visualVelocity < 0) {
          _moveBack();
        } else if (visualVelocity > 0) {
          _moveForward();
        }
      });
    } else if (animationController.value < -0.3) {
      animationController.reverse().whenComplete(() {
        _moveBack();
      });
    } else if (animationController.value > 0.3) {
      animationController.forward().whenComplete(() {
        _moveForward();
      });
    } else {
      animationController.animateTo(0);
    }
  }
}
