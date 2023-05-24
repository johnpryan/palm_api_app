// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
      Prompt.fromJson(json['prompt'] as Map<String, dynamic>),
      candidateCount: json['candidateCount'] as int? ?? 1,
      temperature: json['temperature'] as int? ?? 1,
    );

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'prompt': instance.prompt,
      'candidateCount': instance.candidateCount,
      'temperature': instance.temperature,
    };

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      (json['candidates'] as List<dynamic>)
          .map((e) => ResponseMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['messages'] as List<dynamic>)
          .map((e) => ResponseMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'candidates': instance.candidates,
      'messages': instance.messages,
    };

ResponseMessage _$ResponseMessageFromJson(Map<String, dynamic> json) =>
    ResponseMessage(
      json['author'] as String,
      json['content'] as String,
    );

Map<String, dynamic> _$ResponseMessageToJson(ResponseMessage instance) =>
    <String, dynamic>{
      'author': instance.author,
      'content': instance.content,
    };

Prompt _$PromptFromJson(Map<String, dynamic> json) => Prompt(
      context: json['context'] as String?,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => PromptData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => Example.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PromptToJson(Prompt instance) => <String, dynamic>{
      'context': instance.context,
      'examples': instance.examples,
      'messages': instance.messages,
    };

Example _$ExampleFromJson(Map<String, dynamic> json) => Example(
      PromptData.fromJson(json['input'] as Map<String, dynamic>),
      PromptData.fromJson(json['output'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExampleToJson(Example instance) => <String, dynamic>{
      'input': instance.input,
      'output': instance.output,
    };

PromptData _$PromptDataFromJson(Map<String, dynamic> json) => PromptData(
      json['content'] as String,
    );

Map<String, dynamic> _$PromptDataToJson(PromptData instance) =>
    <String, dynamic>{
      'content': instance.content,
    };
