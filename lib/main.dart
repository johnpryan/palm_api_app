// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:palm_api_app/api.dart';

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
  List<ChatMessage> responses = [];
  bool loading = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
                controller: _scrollController,
                itemBuilder: (context, idx) {
                  final chatMessage = responses[idx];
                  if (chatMessage.error != null) {
                    return TextButton(
                        onPressed: () {
                          responses.removeLast();
                          setState(() {});
                          _makeRequest(context, text: chatMessage.text);
                        },
                        child: Text(
                          "Failed to make request! Tap to retry.",
                          style: TextStyle(color: Colors.red),
                        ));
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: chatMessage.isPrompt!
                          ? Colors.cyan[50]
                          : Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(bottom: 8),
                    child: MarkdownBody(
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                        styleSheet: MarkdownStyleSheet(
                          // body color
                          blockquoteDecoration: BoxDecoration(
                            color: chatMessage.isPrompt!
                                ? Colors.cyan[50]
                                : Colors.blueGrey[50],
                          ),
                        ),
                        selectable: true,
                        data: responses[idx].text),
                  );
                },
                itemCount: responses.length,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 16,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(hintText: 'Enter a prompt...'),
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
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

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _makeRequest(BuildContext context, {String? text}) async {
    try {
      String? prompt;
      if (text == null) {
        prompt = _textEditingController.text;
      } else {
        prompt = text;
      }
      if (prompt.isEmpty) {
        return;
      }
      responses.add(ChatMessage(text: prompt, isPrompt: true));
      _textEditingController.clear();
      scrollToBottom();
      setState(() {
        loading = true;
      });
      var response = await _generate(prompt);
      setState(() {
        responses.add(response);
      });
      scrollToBottom();
    } on ChatMessage catch (_) {
      responses.add(_);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Something went wrong'),
            content: SingleChildScrollView(
              child: Text('${_.error}'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  scrollToBottom();
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

  Future<ChatMessage> _generate(String prompt) async {
    try {
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

      return ChatMessage.fromResponse(buf.toString());
    } catch (e) {
      throw ChatMessage(text: prompt, error: e, isPrompt: true);
    }
  }
}

class ChatMessage {
  final String text;

  /// defaults to false
  /// if true, the message represents a prompt
  final bool? isPrompt;
  final Object? error;

  ChatMessage({required this.text, this.isPrompt = false, this.error});

  ChatMessage.fromResponse(String response)
      : text = response,
        error = null,
        isPrompt = false;
}
