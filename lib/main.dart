import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/image_render.dart';

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response =
      await client.get(Uri.https('jsonplaceholder.typicode.com', 'photos'));

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePhotos, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

Future<List<Content>> fetchContents(http.Client client) async {
  final response = await client.get(
      Uri.https(
          'tlg.itban.com', 'api', {'action': 'content-list2', 'test': '1'}),
      headers: {'Access-Control-Allow-Origin': '*'});

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseContents, response.body);
}

List<Content> parseContents(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Content>((json) => Content.fromJson(json)).toList();
}

class Content {
  final String id;
  final String title;
  final String content;
  final String img;
  final String date;
  final String author;
  final String url;
  final String mediaType;
  final String datefmt;
  Content(
      {this.id,
      this.title,
      this.content,
      this.img,
      this.date,
      this.author,
      this.url,
      this.mediaType,
      this.datefmt});
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      img: json['img'] as String,
      date: json['date'] as String,
      author: json['author'] as String,
      url: json['url'] as String,
      mediaType: json['mediatype'] as String,
      datefmt: json['datefmt'] as String,
    );
  }
}

class Photo {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({this.albumId, this.id, this.title, this.url, this.thumbnailUrl});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['albumId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Talapgap';

    return MaterialApp(
      title: appTitle,
      theme: ThemeData(fontFamily: 'Sarabun'),
      home: MyHomePage(title: appTitle),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Content content;
  DetailPage({this.content});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onDoubleTap: () {
        Navigator.pop(context);
      },
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
              alignment: FractionalOffset.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
          Container(
            padding: EdgeInsets.all(0),
            height: 252,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(content.img),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Text(content.title,
                style: TextStyle(
                    height: 0.85, fontSize: 28, color: Colors.deepPurple)),
          ),
          /*
          Container(
            padding: EdgeInsets.all(10),
            height: 2000,
            child: Text(content.content,
                style:
                    TextStyle(height: 1, fontSize: 18, color: Colors.black87)),
          ),
          */
          Container(
            padding: EdgeInsets.all(0),
            child: Html(
                data: '<p>' +
                    content.content +
                    '<style>*{font-size:20pt;}</style>',
                style: {
                  "p": Style(
                      fontSize: FontSize.xLarge,
                      lineHeight: LineHeight.percent(80)),
                }),
          ),
        ],
      )),
    ));
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(        title: Text('Talapgap'),      ),
      body: FutureBuilder<List<Content>>(
        future: fetchContents(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ContentsList(contents: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class ContentsList extends StatelessWidget {
  final List<Content> contents;

  ContentsList({Key key, this.contents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return DetailPage(content: contents[index]);
                }));
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        padding: EdgeInsets.all(0),
                        height: 180,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(contents[index].img),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Padding(
                                padding: EdgeInsets.all(1),
                                child: Container(
                                    padding: EdgeInsets.all(5),
                                    color: Color.fromARGB(180, 0, 0, 0),
                                    child: Text(contents[index].title,
                                        style: TextStyle(
                                            color: Colors.white,
                                            height: 0.85,
                                            fontSize: 16)))))),
                    /*Container(
                      padding: EdgeInsets.all(10),
                      height: 60,
                      child: Text(contents[index].title,
                          style: TextStyle(
                            fontSize: 18,
                            height: 0.8,
                          )),
                    ),*/
                  ]));
        });
  }
}

class PhotosList extends StatelessWidget {
  final List<Photo> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return Image.network(photos[index].thumbnailUrl);
      },
    );
  }
}
