import 'package:flutter/material.dart';
import 'dart:ui' as ui show window;

import 'package:flutter/services.dart';
import 'package:flutter_alpha_appbar/line_step.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();
  double navAlpha = 0;
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      var offset = scrollController.offset;
      if (offset < 0) {
        if (navAlpha != 0) {
          setState(() {
            navAlpha = 0;
          });
        }
      } else if (offset < 50) {
        setState(() {
          navAlpha = 1 - (50 - offset) / 50;
        });
      } else if (navAlpha != 1) {
        setState(() {
          navAlpha = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
        value: navAlpha > 0.5
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    padding: EdgeInsets.only(top: 0),
                    children: <Widget>[
                      _headerView(),
                      _contentList(),
                    ],
                  ),
                ),
              ],
            ),
            _buildNavWidget(),
          ],
        ),
      ),
    );
  }

  void back() {
    Navigator.pop(context);
  }

  Widget _buildNavWidget() {
    return Stack(
      children: <Widget>[
        Opacity(
            opacity: 1 - navAlpha,
            child: Container(
              width: 44,
              height: kToolbarHeight +
                  MediaQueryData.fromWindow(ui.window).padding.top,
              padding: EdgeInsets.fromLTRB(
                  5, MediaQueryData.fromWindow(ui.window).padding.top, 0, 0),
              child: GestureDetector(
                onTap: back,
                child: Container(
                  color: Colors.orange,
                  width: 20,
                  height: 30,
                ),
              ),
            )),
        Opacity(
          opacity: navAlpha,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                5, MediaQueryData.fromWindow(ui.window).padding.top, 0, 0),
            height: kToolbarHeight +
                MediaQueryData.fromWindow(ui.window).padding.top,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                ),
                Expanded(
                  child: Text(
                    'novel.name',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 44,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _headerView() {
    return Container(
      height: 200,
      color: Colors.cyan,
    );
  }

  List list = [
    {
      'title': '这种情况下Container的宽高铺满，我们给他套上IntrinsicWidth，不设置宽/高步长',
      'content': '可以讲子控件的高度调整至实'
    },
    {
      'title': 'IntrinsicHeight',
      'content': '可以讲子控件的高度调整至实际高度。下面这个例子如果不使用IntrinsicHeight的情况下，'
    },
    {
      'title': 'IntrinsicHeight',
      'content':
          '可以讲子控件的高度调整至实际高度。下面这个例子如果不使用IntrinsicHeight的情况下，第一个Container将会撑满整个body的高度，但使用了IntrinsicHeight高度会约束在50。这里Row的高度时需要有子内容的最大高度来决定的，但是第一个Container本身没有高度，有没有子控件，那么他就会去撑满父控件，然后发现父控件Row也是不具有自己的高度的，就撑满了body的高度。IntrinsicHeight就起到了约束Row实际高度的作用'
    },
    {
      'title': '可以发现Container宽度被压缩到50，但是高度没有变化。我们再设置宽度步长为11',
      'content': '这里设置步长会影响到子控件最后大小'
    },
      {
      'title': '可以发现Container宽度被压缩到50，但是高度没有变化。我们再设置宽度步长为11',
      'content': '这里设置步长会影响到子控件最后大小'
    }
  ];

  Widget _contentList() {
    return Container(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: list.map((e) {
          final index = list.indexOf(e);
          return _lineItems(e, index);
        }).toList(),
      ),
    );
  }

  Widget _lineItems(res, index) {
    return Container(
      decoration: BoxDecoration(
          // color: Colors.cyan,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      padding: EdgeInsets.only(left: 15),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: LineStep(
        key: Key('step$index'),
        isTop: index == 0,
        isBottom: index == list.length - 1,
        child: rightWidget(res),
      ),
    );
  }

  Widget leftWidget() {
    return Container(
      width: 20,
      // height: 200,
      // color: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 5,
            color: Colors.blue,
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
            color: Colors.blue,
          )),
        ],
      ),
    );
  }

  Widget rightWidget(res) {
    return Container(
      // color: Colors.blue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 15),
          Text(
            res['title'],
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            res['content'],
            style: TextStyle(color: Colors.orange, fontSize: 15),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
