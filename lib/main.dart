import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'utis/extension.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Cube(),
    );
  }
}

class Cube extends StatefulWidget {
  Cube({Key key}) : super(key: key);

  @override
  _CubeState createState() => _CubeState();
}

class _CubeState extends State<Cube> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool _canBeDragged = false;
  double delta = 0;
  final double maxSlide = 300.0;

  var index = 0;
  var children = <Widget>[
    Container(
      color: Colors.red,
      width: 300,
      height: 300,
      child: Center(child: Text("0")),
    ),
    Container(
      color: Colors.yellow,
      width: 300,
      height: 300,
      child: Center(child: Text("1")),
    ),
    Container(
      color: Colors.green,
      width: 300,
      height: 300,
      child: Center(child: Text("2")),
    )
  ];

  @override
  void initState() {
    super.initState();
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
      newIndex = children.length - 1;
    }
    return newIndex;
  }

  int calcNext(int index) {
    var newIndex = index + 1;
    if (newIndex >= children.length) {
      newIndex = 0;
    }
    return newIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The Cube"),
      ),
      body: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.blue,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: AnimatedBuilder(
                animation: animationController,
                builder: (context, _) {
                  var defaultOffset = Offset(maxSlide, 0);
                  var defaultRotation = pi / 2;
                  var previous = calcPrevious(index);
                  var next = calcNext(index);
                  var mainOffset =
                      Offset(maxSlide * (animationController.value), 0);
                  var mainRotateY = pi / 2 * -animationController.value;

                  Offset leftOffset = defaultOffset;
                  double leftRotateY = defaultRotation;
                  var leftToCenter =
                      lerpDouble(-1, 0, animationController.value);
                  if (leftToCenter > -1) {
                    leftOffset = Offset(maxSlide * (leftToCenter), 0);
                    leftRotateY = pi / 2 * -leftToCenter;
                  }

                  Offset rightOffset = defaultOffset;
                  double rightRotateY = defaultRotation;
                  var rightToCenter =
                      lerpDouble(1, 0, -animationController.value);
                  if (rightToCenter < 1) {
                    rightOffset = Offset(maxSlide * (rightToCenter), 0);
                    rightRotateY = pi / 2 * -rightToCenter;
                  }

                  return Stack(
                    children: children.mapIndexed((e, i) {
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
                      } else {
                        alignment = animationController.value < 0
                            ? FractionalOffset.centerRight
                            : FractionalOffset.centerLeft;
                        offset = mainOffset;
                        rotation = mainRotateY;
                      }
                      return Transform.translate(
                        offset: offset,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(rotation),
                          alignment: alignment,
                          child: e,
                        ),
                      );
                    }).toList(),
                  );
                }),
          ),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _canBeDragged = animationController.value == 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
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
          index = calcNext(index);
          animationController.value = 0;
        } else if (visualVelocity > 0) {
          index = calcPrevious(index);
          animationController.value = 0;
        }
      });
    } else if (animationController.value < -0.1) {
      animationController.reverse().whenComplete(() {
        index = calcNext(index);
        animationController.value = 0;
      });
    } else if (animationController.value > 0.1) {
      animationController.forward().whenComplete(() {
        index = calcPrevious(index);
        animationController.value = 0;
      });
    } else {
      animationController.animateTo(0);
    }
    print(index);
  }
}
