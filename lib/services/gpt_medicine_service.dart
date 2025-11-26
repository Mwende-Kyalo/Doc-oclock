import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

/// Service for fetching medicine information using GPT API
class GptMedicineService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-3.5-turbo'; // or 'gpt-4' for better results
  
  // Retry configuration
  static const int _maxRetries = 5;
  static const int _baseDelayMs = 1000; // 1 second base delay

  /// Call OpenAI API with retry logic and exponential backoff
  static Future<http.Response> _callOpenAIWithRetry({
    required Map<String, dynamic> payload,
  }) async {
    int retries = 0;
    
    while (retries < _maxRetries) {
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConfig.openaiApiKey}',
          },
          body: jsonEncode(payload),
        );
        
        // If successful or non-retryable error, return immediately
        if (response.statusCode == 200 || 
            response.statusCode == 401 || 
            (response.statusCode != 429 && response.statusCode < 500)) {
          return response;
        }
        
        // If rate limited (429) or server error (5xx), retry with exponential backoff
        if (response.statusCode == 429 || response.statusCode >= 500) {
          retries++;
          if (retries >= _maxRetries) {
            return response; // Return last response after max retries
          }
          
          // Exponential backoff: 2^retry * baseDelay
          final delayMs = (_baseDelayMs * (1 << (retries - 1))).clamp(1000, 30000);
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
        
        return response;
      } catch (e) {
        retries++;
        if (retries >= _maxRetries) {
          rethrow;
        }
        
        // Exponential backoff for network errors
        final delayMs = (_baseDelayMs * (1 << (retries - 1))).clamp(1000, 30000);
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    
    throw Exception('Failed to call OpenAI API after $_maxRetries retries');
  }

  /// Fetches detailed medicine information including side effects, contraindications, and special instructions
  ///
  /// Returns a map with:
  /// - 'sideEffects': List of common and serious side effects
  /// - 'contraindications': Situations when the medicine should NOT be taken
  /// - 'specialInstructions': Important instructions (e.g., take with food, avoid during pregnancy)
  /// - 'generalInfo': General information about the medicine
  static Future<Map<String, String>> getMedicineInfo(
      String medicineName) async {
    try {
      final prompt = '''
You are a medical information assistant. Provide detailed, accurate, and safety-focused information about the medication: $medicineName

Please provide information in the following structured format:

1. **Side Effects**: List common and serious side effects. Separate common from serious side effects.

2. **Contraindications**: List situations when this medicine should NOT be taken (e.g., pregnancy, certain medical conditions, allergies, interactions with other medications).

3. **Special Instructions**: Provide important instructions such as:
   - When to take it (with/without food, empty stomach, etc.)
   - Time of day recommendations
   - What to avoid while taking this medication
   - Storage instructions
   - Any other critical safety information

4. **General Information**: Brief overview of what this medication is used for.

Format your response clearly with sections. Be specific and prioritize safety information.
''';

      final payload = {
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful medical information assistant. Provide accurate, safety-focused information about medications. Always prioritize patient safety and include warnings about contraindications and special instructions.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature':
            0.3, // Lower temperature for more factual, consistent responses
        'max_tokens': 2000, // Increased for more detailed responses
      };
      
      final response = await _callOpenAIWithRetry(payload: payload);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if there's an error in the response
        if (data.containsKey('error')) {
          final error = data['error'];
          throw Exception('API Error: ${error['message'] ?? 'Unknown error'}');
        }

        if (data['choices'] == null || (data['choices'] as List).isEmpty) {
          throw Exception('No response from API');
        }

        final content = data['choices'][0]['message']['content'] as String;

        // Parse the response into structured sections
        return _parseMedicineInfo(content);
      } else if (response.statusCode == 401) {
        throw Exception(
            'Invalid API key. Please check your OpenAI API configuration.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        final errorBody = response.body;
        try {
          final errorData = jsonDecode(errorBody);
          if (errorData.containsKey('error')) {
            throw Exception(
                'API Error: ${errorData['error']['message'] ?? 'Unknown error'}');
          }
        } catch (_) {
          // If parsing fails, use the raw response
        }
        final errorMsg =
            errorBody.length > 200 ? errorBody.substring(0, 200) : errorBody;
        throw Exception(
            'Failed to fetch medicine info (${response.statusCode}): $errorMsg');
      }
    } catch (e) {
      // Re-throw if it's already an Exception with a message
      if (e is Exception) {
        rethrow;
      }
      // Handle network errors and other exceptions
      final errorMsg = e.toString();
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('Failed host lookup')) {
        throw Exception(
            'Network error: Please check your internet connection.');
      } else if (errorMsg.contains('TimeoutException')) {
        throw Exception(
            'Request timeout: The API took too long to respond. Please try again.');
      } else {
        throw Exception('Error fetching medicine information: $errorMsg');
      }
    }
  }

  /// Parses the GPT response into structured sections
  static Map<String, String> _parseMedicineInfo(String content) {
    // Try to extract sections from the response
    String sideEffects = '';
    String contraindications = '';
    String specialInstructions = '';
    String generalInfo = '';

    // Split by common section headers
    final lines = content.split('\n');
    String currentSection = '';

    for (var line in lines) {
      final lowerLine = line.toLowerCase().trim();

      if (lowerLine.contains('side effect')) {
        currentSection = 'sideEffects';
        sideEffects = line.replaceAll(RegExp(r'^\d+\.?\s*\*?\*?'), '').trim();
      } else if (lowerLine.contains('contraindication') ||
          lowerLine.contains('should not')) {
        currentSection = 'contraindications';
        contraindications =
            line.replaceAll(RegExp(r'^\d+\.?\s*\*?\*?'), '').trim();
      } else if (lowerLine.contains('special instruction') ||
          lowerLine.contains('instruction')) {
        currentSection = 'specialInstructions';
        specialInstructions =
            line.replaceAll(RegExp(r'^\d+\.?\s*\*?\*?'), '').trim();
      } else if (lowerLine.contains('general') ||
          lowerLine.contains('overview')) {
        currentSection = 'generalInfo';
        generalInfo = line.replaceAll(RegExp(r'^\d+\.?\s*\*?\*?'), '').trim();
      } else if (line.trim().isNotEmpty) {
        // Add to current section
        switch (currentSection) {
          case 'sideEffects':
            sideEffects += '\n$line';
            break;
          case 'contraindications':
            contraindications += '\n$line';
            break;
          case 'specialInstructions':
            specialInstructions += '\n$line';
            break;
          case 'generalInfo':
            generalInfo += '\n$line';
            break;
        }
      }
    }

    // If parsing didn't work well, return the full content in generalInfo
    if (sideEffects.isEmpty &&
        contraindications.isEmpty &&
        specialInstructions.isEmpty) {
      generalInfo = content;
    }

    return {
      'sideEffects': sideEffects.isEmpty
          ? 'Information not available'
          : sideEffects.trim(),
      'contraindications': contraindications.isEmpty
          ? 'No specific contraindications listed'
          : contraindications.trim(),
      'specialInstructions': specialInstructions.isEmpty
          ? 'Follow your doctor\'s instructions'
          : specialInstructions.trim(),
      'generalInfo': generalInfo.isEmpty
          ? 'General information not available'
          : generalInfo.trim(),
    };
  }

  /// Fetches medicine information for multiple medicines
  /// Batches all requests into a single API call to reduce rate limit issues
  static Future<Map<String, Map<String, String>>> getMultipleMedicineInfo(
    List<String> medicineNames,
  ) async {
    final results = <String, Map<String, String>>{};
    
    if (medicineNames.isEmpty) {
      return results;
    }
    
    // If only one medicine, use the single medicine endpoint
    if (medicineNames.length == 1) {
      try {
        final info = await getMedicineInfo(medicineNames.first);
        results[medicineNames.first] = info;
      } catch (e) {
        final errorMsg = e.toString();
        results[medicineNames.first] = {
          'sideEffects': 'Error: Could not fetch information',
          'contraindications': '',
          'specialInstructions': '',
          'generalInfo': 'Error fetching information for ${medicineNames.first}: ${errorMsg.length > 100 ? errorMsg.substring(0, 100) : errorMsg}',
        };
      }
      return results;
    }
    
    // For multiple medicines, batch them into one request
    try {
      final medicinesList = medicineNames.join(', ');
      final prompt = '''
You are a medical information assistant. Provide detailed, accurate, and safety-focused information about the following medications: $medicinesList

For EACH medication, provide information in the following structured format:

1. **Side Effects**: List common and serious side effects. Separate common from serious side effects.
2. **Contraindications**: List situations when this medicine should NOT be taken.
3. **Special Instructions**: Provide important instructions such as when to take it, what to avoid, storage instructions, etc.
4. **General Information**: Brief overview of what this medication is used for.

Format your response clearly with sections for each medication. Be specific and prioritize safety information.
''';

      final payload = {
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful medical information assistant. Provide accurate, safety-focused information about medications. Always prioritize patient safety and include warnings about contraindications and special instructions.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.3,
        'max_tokens': 4000, // Increased for multiple medicines
      };
      
      final response = await _callOpenAIWithRetry(payload: payload);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('error')) {
          final error = data['error'];
          throw Exception('API Error: ${error['message'] ?? 'Unknown error'}');
        }
        
        if (data['choices'] == null || (data['choices'] as List).isEmpty) {
          throw Exception('No response from API');
        }
        
        final content = data['choices'][0]['message']['content'] as String;
        
        // Parse the batched response
        final parsedResults = _parseMultipleMedicineInfo(content, medicineNames);
        results.addAll(parsedResults);
      } else {
        throw Exception('Failed to fetch medicine info (${response.statusCode})');
      }
    } catch (e) {
      // If batch request fails, fall back to individual requests
      for (var medicineName in medicineNames) {
        if (!results.containsKey(medicineName)) {
          try {
            final info = await getMedicineInfo(medicineName);
            results[medicineName] = info;
          } catch (e) {
            final errorMsg = e.toString();
            results[medicineName] = {
              'sideEffects': 'Error: Could not fetch information',
              'contraindications': '',
              'specialInstructions': '',
              'generalInfo': 'Error fetching information for $medicineName: ${errorMsg.length > 100 ? errorMsg.substring(0, 100) : errorMsg}',
            };
          }
        }
      }
    }

    return results;
  }
  
  /// Parse batched medicine information response
  static Map<String, Map<String, String>> _parseMultipleMedicineInfo(
      String content, List<String> medicineNames) {
    final results = <String, Map<String, String>>{};
    
    // Initialize all medicines with empty data
    for (var name in medicineNames) {
      results[name] = {
        'sideEffects': '',
        'contraindications': '',
        'specialInstructions': '',
        'generalInfo': '',
      };
    }
    
    // Try to parse the response by looking for medicine names
    final lines = content.split('\n');
    String? currentMedicine;
    String currentSection = '';
    
    for (var line in lines) {
      final lowerLine = line.toLowerCase().trim();
      
      // Check if this line mentions a medicine name
      for (var medicineName in medicineNames) {
        if (lowerLine.contains(medicineName.toLowerCase())) {
          currentMedicine = medicineName;
          currentSection = '';
          break;
        }
      }
      
      if (currentMedicine == null) continue;
      
      // Detect section headers
      if (lowerLine.contains('side effect')) {
        currentSection = 'sideEffects';
      } else if (lowerLine.contains('contraindication') || lowerLine.contains('should not')) {
        currentSection = 'contraindications';
      } else if (lowerLine.contains('special instruction') || lowerLine.contains('instruction')) {
        currentSection = 'specialInstructions';
      } else if (lowerLine.contains('general') || lowerLine.contains('overview')) {
        currentSection = 'generalInfo';
      } else if (line.trim().isNotEmpty && currentSection.isNotEmpty) {
        // Add to current section
        final current = results[currentMedicine]![currentSection] ?? '';
        results[currentMedicine]![currentSection] = current.isEmpty 
            ? line.trim() 
            : '$current\n${line.trim()}';
      }
    }
    
    // Fill in defaults for empty sections
    for (var name in medicineNames) {
      final info = results[name]!;
      if (info['sideEffects']!.isEmpty &&
          info['contraindications']!.isEmpty &&
          info['specialInstructions']!.isEmpty &&
          info['generalInfo']!.isEmpty) {
        // If parsing failed, put the whole content in generalInfo
        info['generalInfo'] = content;
      }
      
      info['sideEffects'] = info['sideEffects']!.isEmpty
          ? 'Information not available'
          : info['sideEffects']!.trim();
      info['contraindications'] = info['contraindications']!.isEmpty
          ? 'No specific contraindications listed'
          : info['contraindications']!.trim();
      info['specialInstructions'] = info['specialInstructions']!.isEmpty
          ? 'Follow your doctor\'s instructions'
          : info['specialInstructions']!.trim();
      info['generalInfo'] = info['generalInfo']!.isEmpty
          ? 'General information not available'
          : info['generalInfo']!.trim();
    }
    
    return results;
  }
}
