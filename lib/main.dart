import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PalmApiApp());
}

class PalmApiApp extends StatelessWidget {
  const PalmApiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  String? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Enter a prompt...'),
              controller: _textEditingController,
            ),
            Center(
              child: TextButton(
                onPressed: () async {
                  var haikus = await _generate();
                  setState(() {
                    result = haikus;
                  });
                },
                child: const Text('Generate'),
              ),
            ),
            if (result != null) Text(result!),
          ],
        ),
      ),
    );
  }

  Future<String> _generate() async {
    var productName = _textEditingController.text;
    var haikuCount = 3;
    var apiKey = '';
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=$apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "prompt": {
        "context": "You are an awesome haiku writer.",
        "examples": [
          {
            "input": {"content": "Write a haiku about Google Photos."},
            "output": {
              "content":
                  "Google Photos, my friend\nA journey of a lifetime\nCaptured in pixels"
            }
          }
        ],
        "messages": [
          {"content": "Write a cool, long haiku of for $productName"}
        ]
      },
      "candidate_count": haikuCount,
      "temperature": 1,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print(response.body);
        final decodedResponse = json.decode(response.body);
        String haikus = 'Here are $haikuCount haikus about $productName:\n\n';
        for (var i = 0; i < haikuCount; i++) {
          haikus += '${i + 1}.\n';
          haikus += decodedResponse['candidates'][i]['content'] + '\n\n';
        }
        return haikus;
      } else {
        return 'Request failed with status: ${response.statusCode}.\n\n${response.body}';
      }
    } catch (error) {
      throw Exception('Error sending POST request: $error');
    }
  }
}
