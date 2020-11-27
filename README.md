# flutter_line_step

使用flutter实现一个关于物流进度效果

![](https://img2020.cnblogs.com/blog/950551/202011/950551-20201127094306347-868820220.png)

demo下载地址 https://github.com/qqcc1388/line_step_demo

实现思路也很简单 将每个item拆开分成 leftWidget和rightWiget
leftWidget用来显示竖线和⭕️，可以控制上竖线和下竖线都可以单独隐藏和显示，方便处理第一行和最后一行的竖线显示隐藏问题，进度区域高度跟随rightWidget高度，⭕️位置固定
rightWidget用来控制显示内容区 高度部分 rightWidget内容区 利用column的 mainAxisSize: MainAxisSize.min,来根据内容自适应高度

思路是这个思路，但是在操作的时候发现 左边进度区域和高度无法确定，因为内容区域使用column来自适应高度，如果整个item的高度是不确定的，那么进入区域的高度就不确定，这样就没法实现左边铺满，右边自适应了，那么解决问题的方法只有计算右边内容区的高度，但是计算高度会有一定的误差，这样容易出现左边无法铺满的情况，所有计算文本高度的方案是不可行的

最后发现flutter中提供了IntrinsicHeight这个控件，可以完美解决我的问题
> 根据内部子控件高度来调整高度，它将其子widget的高度调整其本身实际的高度：
将其子控件调整为该子控件的固有高度，举个例子来说，Row中有3个子控件，其中只有一个有高度，默认情况下剩余2个控件将会充满父组件，而使用IntrinsicHeight控件，则3个子控件的高度一致。
此类非常有用，例如，当可以使用无限制的高度并且您希望孩子尝试以其他方式无限扩展以将其自身调整为更合理的高度时，该类非常有用。
但是此类相对昂贵，因为它在最终布局阶段之前添加了一个推测性布局遍历。 避免在可能的地方使用它。 在最坏的情况下，此小部件可能会导致树的深度的布局为O（N²）。所以不推荐使用。

使用IntrinsicHeight将左边和右边包裹起来，这样一旦右边内容区自适应有，那么左边容器的高度和整个item的高度一致了，这样一旦确定了高度，进入部分就可以铺满整个item了 

具体代码 如下：
```
line_step.dart

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

hom.dart
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

```


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
