import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:palm_api_app/src/api.dart';

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
    final body = jsonEncode(
      Request(
        Prompt(
          'You are a haiku writer',
          examples: [
            Example(
              PromptData('Write a haiku about Elephants'),
              PromptData(
                  'Elephants, mighty\nThey roam the savannah\nAcross the plains'),
            )
          ],
          messages: [
            PromptData('Write a cool, long haiku for $productName'),
          ],
        ),
        candidateCount: 3,
      ),
    );

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final decodedResponse = Response.fromJson(json.decode(response.body));
        var haikus = 'Here are ${decodedResponse.candidates.length} haikus:\n\n';
        for (var i = 0; i < decodedResponse.candidates.length; i++) {
          haikus += '${decodedResponse.candidates[i].content}\n\n';
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
