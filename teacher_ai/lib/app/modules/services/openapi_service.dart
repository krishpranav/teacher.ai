import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

int totalTokenUsed = 0;

class OPENAI_API {
  // @breif: STATIC VALUES
  static String DEFAULT_SYSTEM_PROMPT = '';
  static String apiKey = '';
  static String model = 'gpt-3.5-turbo';
  static String selectedLanguage = 'en-US';
  static const String _apiKeyKey = 'openai_api_key';
  static const String _modelKey = 'openai_model';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static String oat() {
    if (apiKey == '') {
      loadOat();
    }
  }

  static void setOat(String value) async {
    apiKey = value;
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }

  static Future<void> loadOat() async {
    try {
      apiKey = await _secureStorage.read(key: _apiKeyKey) ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: loading OAT: $e');
      }
    }
  }

  // @brief: setModel
  static Future<void> setModel(String value) async {
    model = value;
    await _secureStorage.write(key: _modelKey, value: model);
  }
}
