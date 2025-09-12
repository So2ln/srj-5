// lib/services/llm_api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:srj_5/models/llm_result.dart';

class LlmApiClient {
  // TODO: 실제 LLM API 엔드포인트로 변경해야 합니다. (예: Gemini, OpenAI)
  final String _baseUrl =
      "https://your-llm-api-endpoint.com/v1/models/gemini-pro:generateContent";

  // TODO: 실제 API 키로 변경해야 합니다.
  // 경고: 실제 앱에서는 코틀린/스위프트 코드에 키를 숨기고 불러오는 것이 안전합니다.
  final String _apiKey = "YOUR_LLM_API_KEY";

  Future<LlmAnalysisResult?> analyzeWithLlm({required String note}) async {
    // 기획서의 '시스템 프롬프트'와 요청 형식을 여기에 구현합니다.
    final systemPrompt = """
    You are an expert assistant specializing in mapping emotional texts to clinical clusters.
    You MUST ONLY respond with a valid JSON object matching the provided schema. Do not add any explanatory text.
    Calculate scores based ONLY on the provided 'note' text.
    The 'evidence' should be 1 to 5 short keywords or phrases from the 'note'.
    The 'intent' field must be one of: "none", "self-harm-low", "self-harm-medium", "self-harm-high", "other-harm-low", "other-harm-medium", "other-harm-high".
    """;

    final payload = {
      "system_instruction": {
        "parts": [
          {"text": systemPrompt},
        ],
      },
      "contents": [
        {
          "parts": [
            {"text": "Analyze the following user note: $note"},
          ],
        },
      ],
      "generationConfig": {"response_mime_type": "application/json"},
    };

    try {
      debugPrint("--- 실제 LLM API 호출 시도 ---");
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        // Gemini API의 응답 구조에 맞춰 실제 텍스트를 파싱합니다.
        final jsonText =
            responseBody['candidates'][0]['content']['parts'][0]['text'];
        final llmJson = jsonDecode(jsonText);
        debugPrint("LLM API 응답 성공: $llmJson");
        return LlmAnalysisResult.fromJson(llmJson);
      } else {
        debugPrint("LLM API 오류: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("LLM API 호출 예외 발생: $e");
      return null;
    }
  }
}
