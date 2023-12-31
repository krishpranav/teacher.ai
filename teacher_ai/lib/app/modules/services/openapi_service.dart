import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:teacher_ai/app/modules/services/hugging_face_api.dart';

int totalTokensUsed = 0;

class OpenAI_API {
  // @brief: static STRING values
  static String DEFAULT_SYSTEM_PROMPT =
      'You are Teacher.ai, helpful, nice, and humorous AI assistant ready to help with anything, who likes to joke around.';

  static String DEFAULT_SYSTEM_PROMPT_COMPLEX_TASK =
      'You are Teacher.ai, an AI assistant designed teacher students unknown topics with advanced notes. For each step, you offer the user 3 options to choose from. Once the user selects an option, you proceed to the next step based on their choice. After the user has chosen an option for the fifth step, you provide them with a customized, actionable plan based on their previous responses. You only reveal the current step and options to ensure an engaging, interactive experience.';
  static String apiKey = '';
  static String model = 'gpt-3.5-turbo';
  static String selectedLanguage = 'en-US';
  static String systemPrompt = DEFAULT_SYSTEM_PROMPT;
  static const String _apiKeyKey = 'openai_api_key';
  static const String _modelKey = 'openai_model';
  static const String _selectedLanguageKey = 'selected_language';
  static const String _systemPromptKey = 'openai_system_prompt';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// @brief: oat
  static String oat() {
    if (apiKey == '') {
      loadOat();
    }

    return apiKey;
  }

  static void setOat(String value) async {
    apiKey = value;
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }

  static Future<void> loadOat() async {
    try {
      apiKey = await _secureStorage.read(key: _apiKeyKey) ?? '';
      model = (await _secureStorage.read(key: _modelKey)) ?? 'gpt-3.5-turbo';
      selectedLanguage =
          (await _secureStorage.read(key: _selectedLanguageKey)) ?? 'en-US';
      systemPrompt = (await _secureStorage.read(key: _systemPromptKey)) ??
          DEFAULT_SYSTEM_PROMPT;
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: loading OAT: $e');
      }
    }

    await HuggingFace_API.loadOat();
  }

  /// @brief: setModel
  static Future<void> setModel(String value) async {
    model = value;
    await _secureStorage.write(key: _modelKey, value: model);
  }

  static Future<void> setSystemPrompt(String value) async {
    systemPrompt = value;
    await _secureStorage.write(key: _systemPromptKey, value: systemPrompt);
  }

  static Future<void> setSelectedLanguage(String value) async {
    selectedLanguage = value;
    await _secureStorage.write(
        key: _selectedLanguageKey, value: selectedLanguage);
  }

  /// @brief: generateImageURL
  static Future<String?> generateImageUrl(String description) async {
    final queryUrl = 'https://api.openai.com/v1/images/generations';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'prompt': description,
      'n': 1,
      'size': '512x512',
    });
    if (kDebugMode) {
      print('Request URL: $queryUrl');
    }

    final response =
        await http.post(Uri.parse(queryUrl), headers: headers, body: body);
    if (kDebugMode) {
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final imageUrl = jsonResponse['data'][0]['url'];
      if (kDebugMode) {
        print('Generated Image URL: $imageUrl');
      }

      return imageUrl;
    } else {
      throw Exception('Failed to generate image');
    }
  }

  /// @brief: inputSafe
  static Future<bool> isInputSafe(String input) async {
    if (kDebugMode) {
      print('isInputSafe called with input: $input');
    }

    final lambdaUrl = 'YOUR_LAMBDA_FUNCTION_URL';

    final headers = {
      'Content-Type': 'application/json',
    };

    final data = {
      'input': input,
    };

    try {
      print('calling lambda function with input: $input and url: $lambdaUrl');
      final response = await http.post(
        Uri.parse(lambdaUrl),
        headers: headers,
        body: jsonEncode(data),
      );
      if (kDebugMode) {
        print('isInputSafe response status code: ${response.statusCode}');
        print('isInputSafe response headers: ${response.headers}');
        print('isInputSafe response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        bool moderationStatus = responseBody['isSafe'];
        return moderationStatus;
      } else {
        if (kDebugMode) {
          print('isInputSafe error: Status code ${response.statusCode}');
        }
        throw Exception('Failed to get response from Lambda function.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('isInputSafe exception: $e');
      }
      throw e;
    }
  }

  /// @brief: adjustedMaxTokens for the openai
  static int getAdjustedMaxTokens(String inputText,
      {int defaultMaxTokens = 300}) {
    List<String> keywords = [
      'code',
      'snippet',
      'class',
      'function',
      'method',
      'generate',
      'create',
      'build',
      'implement',
      'algorithm',
      'example',
      'template',
      'sample',
      'skeleton',
      'structure',
    ];

    bool containsKeyword(String text, List<String> keywords) {
      return keywords.any((keyword) => text.toLowerCase().contains(keyword));
    }

    if (containsKeyword(inputText, keywords)) {
      return defaultMaxTokens * 3;
    }

    return defaultMaxTokens;
  }

  /// @brief: getResponsefromOPENAI
  static CancelableOperation<String> getResponseFromOpenAI(
    String message, {
    List<Map<String, String?>> previousMessages = const [],
    int maxTries = 1,
    String? customSystemPrompt = null,
  }) {
    final completer = CancelableCompleter<String>();

    if (OpenAI_API.model == 'huggingface') {
      _getResponseFromHuggingFace(
        message,
        completer,
        previousMessages: previousMessages,
      );
    } else {
      _getResponseFromOpenAI(
        message,
        completer,
        previousMessages: previousMessages,
        maxTries: maxTries,
        customSystemPrompt: customSystemPrompt,
      );
    }

    return completer.operation;
  }

  static String formatPrevMessages(
      List<Map<String, String?>> previousMessages) {
    return previousMessages.map((message) {
      return "${message['role']}: ${message['content']}";
    }).join(', ');
  }

  static Future<void> _getResponseFromHuggingFace(
    String message,
    CancelableCompleter<String> completer, {
    List<Map<String, String?>> previousMessages = const [],
  }) async {
    String? finalResponse = '';

    if (HuggingFace_API.apiKey != '') {
      String formattedPrevMessages = formatPrevMessages(previousMessages);
      if (previousMessages.length > 0 && HuggingFace_API.sendMessages()) {
        finalResponse = await HuggingFace_API.generate(
            message + ' previousMessages: ' + formattedPrevMessages);
      } else {
        finalResponse = await HuggingFace_API.generate(message);
      }

      if (finalResponse != null) {
        finalResponse = finalResponse
            .replaceAll('assistant: ', '')
            .replaceAll('previousMessages: ', '')
            .replaceAll('user: ', '')
            .replaceAll('[System message]: ', '');
      }
    } else {
      finalResponse =
          'Please enter your Hugging Face Access Token in the settings.';
    }

    completer.complete(finalResponse);

    return null;
  }

  static Future<void> _getResponseFromOpenAI(
      String message, CancelableCompleter<String> completer,
      {List<Map<String, String?>> previousMessages = const [],
      int maxTries = 1,
      String? customSystemPrompt = null}) async {
    String finalResponse = '';
    String inputMessage = message;
    int tries = 0;

    while (tries < maxTries) {
      if (kDebugMode) {
        print('inputMessage = $inputMessage');
      }
      final apiUrl = 'https://api.openai.com/v1/chat/completions';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final adjustedMaxTokens = getAdjustedMaxTokens(inputMessage);

      final data = {
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                customSystemPrompt == null ? systemPrompt : customSystemPrompt
          },
          ...previousMessages,
          {'role': 'user', 'content': inputMessage}
        ],
        'max_tokens': adjustedMaxTokens,
        'n': 1,
        'stop': null,
        'temperature': 1,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
          String receivedResponse = responseBody['choices'][0]['message']
                  ['content']
              .toString()
              .trim();

          finalResponse += receivedResponse;

          int tokensUsed = responseBody['usage']['total_tokens'];
          totalTokensUsed += tokensUsed;

          double cost = tokensUsed * 0.002 / 1000;
          if (kDebugMode) {
            print('TOKENS used in this response: $tokensUsed');
            print('Cost of this response: \$${cost.toStringAsFixed(5)}');
            print('Total tokens used so far: $totalTokensUsed');
          }

          double totalCost = totalTokensUsed * 0.002 / 1000;
          if (kDebugMode) {
            print('Total cost so far: \$${totalCost.toStringAsFixed(5)}');
          }

          if (responseBody['choices'][0]['finish_reason'] == 'length') {
            inputMessage += receivedResponse;
            int maxLength = 1024 * 10;
            if (inputMessage.length > maxLength) {
              inputMessage =
                  inputMessage.substring(inputMessage.length - maxLength);
            }
            tries++;
          } else {
            break;
          }
        } else {
          throw Exception('Failed to get response from OpenAI API.');
        }
      } catch (e) {
        if (tries + 1 < maxTries) {
          tries++;
          await Future.delayed(Duration(seconds: 2));
        } else {
          finalResponse =
              'Sorry, there was an error processing your request. Please try again later.';
          if (kDebugMode) {
            print('Error: $e');
          }
          break;
        }
      }
    }

    completer.complete(finalResponse);

    return null;
  }
}
