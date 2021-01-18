import 'package:animation/animated/cube.dart';
import 'package:flutter/material.dart';

class CubeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cube"),
      ),
      body: Center(
        child: Cube(
          width: MediaQuery.of(context).size.width,
          children: [
            Image.asset('assets/cube/example1.jpg'),
            Image.asset('assets/cube/example2.jpg'),
            Image.asset('assets/cube/example3.jpg'),
            Image.asset('assets/cube/example4.jpg'),
            Image.asset('assets/cube/example5.jpg'),
          ],
        ),
      ),
    );
  }
}
