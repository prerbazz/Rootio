// lib/services/ai_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Gemini API integration.
// Uses the Gemini model via its OpenAI-compatible REST API.
//
// TO ACTIVATE: Pass the API key during build:
// flutter run --dart-define=GEMINI_API_KEY=your_key
// Or edit the default placeholder below.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AiException implements Exception {
  final String message;
  AiException(this.message);
  @override
  String toString() => message;
}

class AiService {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY',
    defaultValue: '');
  static String model = 'gemini-3.5-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions';
  static const Duration _timeout = Duration(seconds: 15);

  /// Returns true if a real API key has been set and isn't the placeholder
  bool get isConfigured => apiKey.isNotEmpty;

  // ─── Core request helper ──────────────────────────────────────────────

  Future<String?> _chat(String systemPrompt, String userMessage) async {
    if (!isConfigured) return null;

    const int maxRetries = 2;
    Exception? lastException;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('Gemini API: Sending request (Attempt ${attempt + 1})...');
        final response = await http
            .post(
              Uri.parse(_baseUrl),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': model,
                'messages': [
                  {'role': 'system', 'content': systemPrompt},
                  {'role': 'user', 'content': userMessage},
                ],
                'temperature': 0.7,
              }),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          debugPrint('Gemini API: Response received successfully.');
          try {
            final data = jsonDecode(response.body);
            final content =
                data['choices']?[0]?['message']?['content'] as String?;
            if (content == null) {
              throw AiException('Malformed response: missing content field.');
            }
            return content;
          } catch (e) {
            debugPrint('Gemini API: JSON Parsing Failed - $e');
            throw AiException('Failed to parse AI response: $e');
          }
        } else {
          debugPrint(
              'Gemini API: HTTP Error ${response.statusCode} - ${response.body}');
          throw AiException(
              'API Error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('Gemini API Exception: $e');
        if (attempt == maxRetries) {
          break; // All retries exhausted
        }
        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }

    throw AiException(
        'Request failed after ${maxRetries + 1} attempts. Last error: $lastException');
  }

  // ─── Daily Farming Insights ───────────────────────────────────────────

  /// Generate today's farming insights based on user's active plans.
  /// Returns a list of [AiInsight] or fallback static insights if AI unavailable.
  Future<List<AiInsight>> getDailyInsights({
    required String userName,
    required List<CropPlan> activePlans,
    required String climateZone,
    required String experienceLevel,
  }) async {
    if (!isConfigured || activePlans.isEmpty) {
      return _fallbackInsights(activePlans);
    }

    final cropNames = activePlans.map((p) => p.name).join(', ');
    final nextTasks = activePlans
        .map((p) {
          for (final week in p.weeks) {
            for (final task in week.tasks) {
              if (!task.isCompleted) return '${p.name}: ${task.title}';
            }
          }
          return null;
        })
        .whereType<String>()
        .take(3)
        .join('; ');

    final system =
        '''You are Rootio, a friendly and concise urban farming assistant.
Give practical, actionable daily farming tips. Keep each tip under 15 words.
Respond ONLY with a JSON array of 3 objects with keys: icon (emoji), text (string), type (tip/warning/motivation).
Example: [{"icon":"💧","text":"Water tomatoes in the morning to avoid fungal issues","type":"tip"}]''';

    final user =
        '''Farmer: $userName | Climate: $climateZone | Level: $experienceLevel
Growing: $cropNames
Pending tasks: $nextTasks
Give 3 personalized farming insights for today.''';

    try {
      final raw = await _chat(system, user);
      if (raw != null) {
        try {
          final jsonStr = raw.contains('[')
              ? raw.substring(raw.indexOf('['), raw.lastIndexOf(']') + 1)
              : raw;
          final list = jsonDecode(jsonStr) as List;
          return list
              .map((e) => AiInsight.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Daily Insights AI fallback due to error: $e');
    }
    return _fallbackInsights(activePlans);
  }

  // ─── Personalized Tips for a crop ────────────────────────────────────

  Future<List<String>> getCropTips({
    required String cropName,
    required String location,
    required String climateZone,
    required String weekTitle,
  }) async {
    if (!isConfigured) return _fallbackCropTips(cropName);

    final system = '''You are a concise farming expert. 
Give exactly 3 practical tips for growing this crop at this stage.
Respond ONLY with a JSON array of 3 strings.
Example: ["Water in the morning","Check for pests weekly","Add compost now"]''';

    final user =
        'Crop: $cropName | Location: $location | Climate: $climateZone | Stage: $weekTitle';

    try {
      final raw = await _chat(system, user);
      if (raw != null) {
        try {
          final jsonStr = raw.contains('[')
              ? raw.substring(raw.indexOf('['), raw.lastIndexOf(']') + 1)
              : raw;
          final list = jsonDecode(jsonStr) as List;
          return list.cast<String>();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Crop Tips AI fallback due to error: $e');
    }
    return _fallbackCropTips(cropName);
  }

  // ─── Motivational Message ─────────────────────────────────────────────

  Future<String> getMotivationalMessage({
    required String userName,
    required int streakDays,
    required int tasksCompleted,
  }) async {
    if (!isConfigured) {
      return _fallbackMotivation(streakDays);
    }

    final system =
        'You are an encouraging farming coach. Give one short motivational message (max 20 words) for an urban farmer.';
    final user =
        'Farmer: $userName | Streak: $streakDays days | Tasks done this week: $tasksCompleted';

    try {
      final raw = await _chat(system, user);
      return raw?.trim() ?? _fallbackMotivation(streakDays);
    } catch (e) {
      debugPrint('Motivation AI fallback due to error: $e');
      return _fallbackMotivation(streakDays);
    }
  }

  // ─── Onboarding-based Crop Recommendations ────────────────────────────

  Future<List<String>> getOnboardingRecommendations({
    required String location,
    required String waterAvailability,
    required String climateZone,
    required String experienceLevel,
    required String timeCommitment,
  }) async {
    if (!isConfigured) return [];

    final system =
        '''You are a farming advisor. Recommend 5 suitable crops based on user constraints.
Respond ONLY with a JSON array of 5 crop name strings.
Example: ["Spinach","Coriander","Lettuce","Mint","Marigold"]''';

    final user =
        'Location: $location | Water: $waterAvailability | Climate: $climateZone | Experience: $experienceLevel | Time: $timeCommitment';

    try {
      final raw = await _chat(system, user);
      if (raw != null) {
        try {
          final jsonStr = raw.contains('[')
              ? raw.substring(raw.indexOf('['), raw.lastIndexOf(']') + 1)
              : raw;
          final list = jsonDecode(jsonStr) as List;
          return list.cast<String>();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Onboarding AI fallback due to error: $e');
    }
    return [];
  }

  /// Answer a free-form question about a specific crop.
  Future<String?> askCropQuestion({
    required String question,
    required String cropName,
    required String currentWeek,
    required String location,
    required String climate,
  }) async {
    if (!isConfigured) return null;

    final system =
        'You are a concise urban farming expert. Answer in 2-4 sentences max. Be practical and specific.';
    final user =
        'Crop: $cropName | Location: $location | Climate: $climate | Stage: $currentWeek\\nQuestion: $question';

    return _chat(system, user);
  }

  // ─── Fallbacks (when AI is not configured / offline) ─────────────────

  List<AiInsight> _fallbackInsights(List<CropPlan> plans) {
    final insights = <AiInsight>[];
    if (plans.isNotEmpty) {
      final plan = plans.first;
      for (final week in plan.weeks) {
        for (final task in week.tasks) {
          if (!task.isCompleted) {
            insights.add(AiInsight(
              icon: '📋',
              text: '${plan.name}: ${task.title}',
              type: 'tip',
            ));
            break;
          }
        }
        if (insights.isNotEmpty) break;
      }
    }
    insights.addAll([
      AiInsight(
          icon: '💧', text: 'Water your plants early morning', type: 'tip'),
      AiInsight(
          icon: '☀️', text: 'Ensure 6 hours of sunlight daily', type: 'tip'),
      AiInsight(
          icon: '✂️', text: 'Prune dead leaves to boost growth', type: 'tip'),
    ]);
    return insights.take(3).toList();
  }

  List<String> _fallbackCropTips(String cropName) => [
        'Water $cropName regularly in the morning',
        'Check soil moisture before watering',
        'Monitor for pests and remove manually',
      ];

  String _fallbackMotivation(int streak) {
    if (streak >= 7)
      return '🔥 Amazing! $streak days streak — keep it growing!';
    if (streak >= 3) return '🌱 Great progress! $streak days and counting!';
    return '🌿 Every great garden starts with one seed. Keep going!';
  }
}
