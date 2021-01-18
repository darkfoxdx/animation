import 'package:flutter/material.dart';

import 'package:animation/animation.dart';

class CubeScreen extends StatefulWidget {
  @override
  _CubeScreenState createState() => _CubeScreenState();
}

class _CubeScreenState extends State<CubeScreen> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cube"),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 100,
            child: Text(
              "Current page: ${_index + 1}",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Cube(
              contentWidth: MediaQuery.of(context).size.width,
              children: [
                Image.asset('assets/cube/example1.jpg'),
                Image.asset('assets/cube/example2.jpg'),
                Image.asset('assets/cube/example3.jpg'),
                Image.asset('assets/cube/example4.jpg'),
                Image.asset('assets/cube/example5.jpg'),
              ],
              onPageChanged: (index) {
                setState(() {
                  _index = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
