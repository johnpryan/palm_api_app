import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

@JsonSerializable()
class Request {
  final Prompt prompt;
  final int candidateCount;
  final int temperature;

  Request(
    this.prompt, {
    this.candidateCount = 1,
    this.temperature = 1,
  });

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestToJson(this);
}

@JsonSerializable()
class Response {
  List<ResponseMessage> candidates;
  List<ResponseMessage> messages;

  Response(this.candidates, this.messages);

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}


@JsonSerializable()
class ResponseMessage {
  String author;
  String content;
  ResponseMessage(this.author, this.content);

  factory ResponseMessage.fromJson(Map<String, dynamic> json) =>
      _$ResponseMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseMessageToJson(this);
}

@JsonSerializable()
class Prompt {
  String context;
  List<Example> examples;
  List<PromptData> messages;

  Prompt(this.context, {this.messages = const [], this.examples = const []});

  factory Prompt.fromJson(Map<String, dynamic> json) => _$PromptFromJson(json);
  Map<String, dynamic> toJson() => _$PromptToJson(this);
}

@JsonSerializable()
class Example {
  PromptData input;
  PromptData output;

  Example(this.input, this.output);

  factory Example.fromJson(Map<String, dynamic> json) =>
      _$ExampleFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleToJson(this);
}

@JsonSerializable()
class PromptData {
  String content;

  PromptData(this.content);

  factory PromptData.fromJson(Map<String, dynamic> json) =>
      _$PromptDataFromJson(json);
  Map<String, dynamic> toJson() => _$PromptDataToJson(this);
}
