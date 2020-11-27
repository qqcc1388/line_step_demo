import 'package:flutter/material.dart';

class LineStep extends StatefulWidget {
  final Widget child;
  final isTop;
  final isBottom;
  LineStep({
    key,
    @required this.child,
    this.isTop: false,
    this.isBottom: false,
  }) : super(key: key);
  @override
  _LineStepState createState() => _LineStepState();
}

class _LineStepState extends State<LineStep> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            leftWidget(),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }

  Widget leftWidget() {
    return Container(
      width: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 5,
            color: widget.isTop ? Colors.transparent : Colors.blue,
            height: 20,
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(8)),
          ),
          Expanded(
              child: Container(
            width: 5,
            color: widget.isBottom ? Colors.transparent : Colors.blue,
          )),
        ],
      ),
    );
  }
}
