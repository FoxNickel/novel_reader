import 'package:flutter/material.dart';

void main() => runApp(new NovelApp());

class NovelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Novel Reader",
      home: new NovelList(),
      theme: new ThemeData(primaryColor: Colors.white),
    );
  }
}

class NovelList extends StatefulWidget {
  @override
  _NovelStateState createState() => new _NovelStateState();
}

class _NovelStateState extends State<NovelList> {
  final chapterUrl = "https://www.xxbiquge.com/78_78513/";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Nover Reader"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.vertical_align_bottom), onPressed: null)
        ],
      ),
      /*body: new Center(
        child: new Text("Hello,World"),
      ),*/
      body: _buildChapterList(),
    );
  }

  Widget _buildChapterList() {
    return new ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemBuilder: (context, i) {
          return new ListTile(
            title: new Text(chapterUrl),
          );
        });
  }
}
