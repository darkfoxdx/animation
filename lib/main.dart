import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

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
  final double maxSlide = 300.0;

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
        onTap: toggle,
        child: Container(
          color: Colors.blue,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: AnimatedBuilder(
                animation: animationController,
                builder: (context, _) {
                  var mainOffset =
                      Offset(maxSlide * (animationController.value), 0);
                  var mainRotateY = pi / 2 * -animationController.value;

                  Offset leftOffset = Offset(-maxSlide, 0);
                  double leftRotateY = -pi / 2;
                  var leftToCenter =
                      lerpDouble(-1, 0, animationController.value);
                  if (leftToCenter > -1) {
                    leftOffset = Offset(maxSlide * (leftToCenter), 0);
                    leftRotateY = pi / 2 * -leftToCenter;
                  }

                  Offset rightOffset = Offset(maxSlide, 0);
                  double rightRotateY = pi / 2;
                  var rightToCenter =
                      lerpDouble(1, 0, -animationController.value);
                  if (rightToCenter < 1) {
                    rightOffset = Offset(maxSlide * (rightToCenter), 0);
                    rightRotateY = pi / 2 * -rightToCenter;
                  }
                  
                  return Stack(
                    children: [
                      Transform.translate(
                        offset: leftOffset,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(leftRotateY),
                          alignment: FractionalOffset.centerRight,
                          child: Container(
                            color: Colors.green,
                            width: 300,
                            height: 300,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: rightOffset,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(rightRotateY),
                          alignment: FractionalOffset.centerLeft,
                          child: Container(
                            color: Colors.yellow,
                            width: 300,
                            height: 300,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: mainOffset,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(mainRotateY),
                          alignment: animationController.value < 0
                              ? FractionalOffset.centerRight
                              : FractionalOffset.centerLeft,
                          child: Container(
                            color: Colors.red,
                            width: 300,
                            height: 300,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed;
    bool isDragCloseFromRight = animationController.isCompleted;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (animationController.value < -0.5) {
      animationController.reverse();
    } else if (animationController.value > 0.5) {
      animationController.forward();
    } else {
      animationController.animateTo(0);
    }
  }
}
