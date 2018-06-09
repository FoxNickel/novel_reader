import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

final appTitle = "元尊";

void main() => runApp(new NovelApp());

class NovelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: appTitle,
      home: new NovelList(),
      theme: new ThemeData(primaryColor: Colors.white),
    );
  }
}

// 小说列表页
class NovelList extends StatefulWidget {
  @override
  _NovelStateState createState() => new _NovelStateState();
}

class _NovelStateState extends State<NovelList> {
  final host = "https://www.xxbiquge.com";
  final chapterUrl = "https://www.xxbiquge.com/78_78513/";
  List<String> chapterNameList;
  List<String> chapterNameListReversed;
  List<String> chapterUrlList;
  Map<String, String> chapterInfo;
  bool reverse = true;

  @override
  Widget build(BuildContext context) {
    if (chapterNameList == null) {
      // 如果章节信息为空就获取章节信息
      // 不能不判断，因为获取信息之后会调用setstate，又调用getChapterInfo方法，然后形成死循环
      // 因此，当获取到章节信息之就不去再获取了
      getChapterInfo();
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(appTitle),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.vertical_align_bottom),
              onPressed: () {
                reverse = !reverse;
                setState(() {});
              })
        ],
      ),
      /*body: new Center(
        child: new Text("Hello,World"),
      ),*/
      body: _buildChapterList(),
    );
  }

  // 构建列表每一行，也就是列表每一行的布局
  Widget _buildRow(BuildContext context, String item) {
    return new ListTile(
        title: new Text(item),
        onTap: () {
          _navigateToContent(item);
        });
  }

  // 构建listView
  Widget _buildChapterList() {
    if (chapterNameList != null) {
      // 加载到了章节数据
      Iterable<Widget> listTitles;
      if (reverse) {
        listTitles = chapterNameListReversed.map((String item) {
          return _buildRow(context, item);
        });
      } else {
        listTitles = chapterNameList.map((String item) {
          return _buildRow(context, item);
        });
      }
      return new ListView(
        children: listTitles.toList(),
      );
    } else {
      // 正在加载章节数据
      return new Center(child: new Text("正在加载..."));
    }
  }

  // 获取章节信息
  void getChapterInfo() async {
    // 异步发起网络请求获取html界面
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(chapterUrl));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();

    // 获取到了内容，进行正则表达式分割，获取章节名称和链接
    if (responseBody != null) {
      chapterInfo = new Map<String, String>();
      chapterNameList = new List<String>();
      chapterNameListReversed = new List<String>();
      chapterUrlList = new List<String>();
      RegExp regExp = new RegExp('<dd>.*?href="(.*?)">(.*?)</a></dd>');
      Iterable<Match> matches = regExp.allMatches(responseBody);
      // 获取章节名称和链接，存入对应数组
      for (Match m in matches) {
        // print(m.group(2));
        // print(m.group(1));
        chapterInfo[m.group(2)] = "$host${m.group(1)}";
        chapterNameList.add(m.group(2));
        chapterUrlList.add(m.group(1));
      }
      chapterNameListReversed = chapterNameList.reversed.toList();
      // 获取到章节信息之后通知页面更新
      setState(() {});
    }
  }

  // 跳转到详情页
  void _navigateToContent(String title) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new NovelContent(title, chapterInfo);
    }));
  }
}

// 小说详情页
class NovelContent extends StatefulWidget {
  final String title;
  final Map<String, String> chapterInfo;

  NovelContent(this.title, this.chapterInfo);

  @override
  _NovelContentState createState() =>
      new _NovelContentState(title, chapterInfo);
}

class _NovelContentState extends State<NovelContent> {
  final String title;
  final Map<String, String> chapterInfo;
  String novelContent;
  var fontSize = 18.0;

  _NovelContentState(this.title, this.chapterInfo);

  @override
  Widget build(BuildContext context) {
    if (novelContent == null) {
      getChapterContent();
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.remove),
              onPressed: () {
                fontSize--;
                setState(() {});
              }),
          new IconButton(
              icon: new Icon(Icons.add),
              onPressed: () {
                fontSize++;
                setState(() {});
              })
        ],
      ),
      body: _buildContent(),
    );
  }

  // 构建小说内容
  Widget _buildContent() {
    if (novelContent != null) {
      return new ListView(
        children: <Widget>[
          new ListTile(
            title: new Text(
              novelContent,
              style: new TextStyle(fontSize: fontSize),
            ),
          )
        ],
      );
    } else {
      return new Center(
        child: new Text("正在加载..."),
      );
    }
  }

  void getChapterContent() async {
    // 异步发起网络请求获取html界面
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(chapterInfo[title]));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();

    if (responseBody != null) {
      //print(responseBody);

      RegExp regExp = new RegExp('<div id="content">(.*?)</div>');
      Iterable<Match> matches = regExp.allMatches(responseBody);
      for (Match m in matches) {
        // print(m.group(1));
        novelContent =
            m.group(1).replaceAll("&nbsp;", " ").replaceAll("<br />", "\n");
      }

      setState(() {});
    }
  }
}
