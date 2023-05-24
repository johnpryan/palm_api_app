// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:palm_api_app/api.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Add your PaLM MakerSuite API here:
const _apiKey = '';

void main() {
  runApp(const PalmApiApp());
}

class PalmApiApp extends StatelessWidget {
  const PalmApiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
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
        title: const Text('Flutter + PaLM App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) const LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, idx) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(bottom: 8),
                    child: MarkdownBody(data: responses[idx]),
                  );
                },
                itemCount: responses.length,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:
                        const InputDecoration(hintText: 'Enter a prompt...'),
                    controller: _textEditingController,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        loading = true;
                      });

                      var response = await _generate();
                      setState(() {
                        responses.add(response);
                      });
                    } catch (e) {
                      print('Error: $e');
                    } finally {
                      _textEditingController.clear();
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.send),
                  // child: const Text('Generate'),
                )
              ],
            ),
          ],
        ),
      ),
    );
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
