import 'dart:convert';

import 'package:http/http.dart' as http;
import 'src/api.dart';

class GenerativeLanguageApi {
  final String apiKey;
  GenerativeLanguageApi(this.apiKey);
  
  Future<Response> generate(Request request) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=$apiKey');
    final headers = {'Content-Type': 'application/json'};   
    final body = jsonEncode(request);
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final decodedResponse = Response.fromJson(json.decode(response.body));
        return decodedResponse;
      } else {
        throw Exception('Unexpected HTTP status code: ${response.statusCode}');
      }
    } catch(e) {
      throw Exception('Error sending POST request: $e');
    }
  }
}