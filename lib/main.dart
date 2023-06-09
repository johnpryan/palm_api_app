// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:palm_api_app/api.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Add your PaLM MakerSuite API here:
const _apiKey = '';

void main() {
  runApp(PalmApiApp());
}

class PalmApiApp extends StatelessWidget {
  const PalmApiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _textEditingController = TextEditingController();
  List<String> responses = [];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter + PaLM'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, idx) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(bottom: 8),
                    child: MarkdownBody(selectable: true, data: responses[idx]),
                  );
                },
                itemCount: responses.length,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Enter a prompt...'),
                    controller: _textEditingController,
                    onSubmitted: (String value) {
                      _makeRequest(context);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _makeRequest(context);
                  },
                  icon: Icon(Icons.send),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeRequest(BuildContext context) async {
    try {
      setState(() {
        loading = true;
      });

      var response = await _generate();
      setState(() {
        responses.add(response);
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Something went wrong'),
            content: SingleChildScrollView(
              child: Text('$e'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              )
            ],
          );
        },
      );
    } finally {
      _textEditingController.clear();
      setState(() {
        loading = false;
      });
    }
  }

  Future<String> _generate() async {
    var prompt = _textEditingController.text;
    final api = GenerativeLanguageApi(_apiKey);
    final result = await api.generate(Request(
      Prompt(
        messages: [
          PromptData(prompt),
        ],
      ),
      candidateCount: 1,
    ));

    var buf = StringBuffer();
    for (var i = 0; i < result.candidates.length; i++) {
      buf.writeln(result.candidates[i].content);
      buf.writeln('');
    }

    return buf.toString();
  }
}
