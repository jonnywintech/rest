import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  const GeminiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ChatTurn {
  const ChatTurn(this.role, this.text);

  /// 'user' ili 'model'
  final String role;
  final String text;
}

/// Minimalni klijent za Gemini REST API (generateContent).
class GeminiService {
  GeminiService({required this.apiKey, required this.model, http.Client? client})
      : _client = client ?? http.Client();

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final String apiKey;
  final String model;
  final http.Client _client;

  Future<String> generate({
    required String systemPrompt,
    required List<ChatTurn> turns,
    double temperature = 0.8,
  }) async {
    if (apiKey.isEmpty) {
      throw const GeminiException('Nedostaje Gemini API ključ.');
    }

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': _normalize(turns)
          .map((t) => {
                'role': t.role,
                'parts': [
                  {'text': t.text},
                ],
              })
          .toList(),
      'generationConfig': {'temperature': temperature},
    };

    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$_baseUrl/$model:generateContent'),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw const GeminiException('Mira se predugo ne javlja. Pokušaj ponovo.');
    } catch (_) {
      throw const GeminiException(
          'Nema veze sa serverom. Proveri internet i pokušaj ponovo.');
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw GeminiException('Neočekivan odgovor servera (${res.statusCode}).');
    }

    if (res.statusCode != 200) {
      final message = (data['error'] as Map?)?['message'] as String?;
      throw GeminiException(_friendlyError(res.statusCode, message));
    }

    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      final reason = (data['promptFeedback'] as Map?)?['blockReason'];
      throw GeminiException(reason != null
          ? 'Odgovor je blokiran ($reason). Pokušaj da preformulišeš poruku.'
          : 'Prazan odgovor. Pokušaj ponovo.');
    }

    final parts =
        ((candidates.first as Map)['content'] as Map?)?['parts'] as List? ?? [];
    final text = parts
        .whereType<Map>()
        .where((p) => p['thought'] != true)
        .map((p) => p['text'] as String? ?? '')
        .join()
        .trim();
    if (text.isEmpty) {
      throw const GeminiException('Prazan odgovor. Pokušaj ponovo.');
    }
    return text;
  }

  /// Gemini očekuje da razgovor počne korisnikom i da se uloge smenjuju.
  List<ChatTurn> _normalize(List<ChatTurn> turns) {
    final result = <ChatTurn>[];
    for (final t in turns) {
      if (t.text.trim().isEmpty) continue;
      if (result.isEmpty && t.role != 'user') continue;
      if (result.isNotEmpty && result.last.role == t.role) {
        result[result.length - 1] =
            ChatTurn(t.role, '${result.last.text}\n\n${t.text}');
      } else {
        result.add(t);
      }
    }
    return result;
  }

  String _friendlyError(int status, String? message) {
    switch (status) {
      case 400:
        if (message != null && message.toLowerCase().contains('api key')) {
          return 'API ključ nije ispravan. Proveri ga u Profilu → Mira (AI).';
        }
        return 'Neispravan zahtev: ${message ?? status}';
      case 401:
      case 403:
        return 'API ključ nije ispravan ili nema dozvolu. Proveri ga u Profilu → Mira (AI).';
      case 404:
        return 'Model „$model“ nije pronađen. Izaberi drugi model u Profilu → Mira (AI).';
      case 429:
        return 'Previše zahteva ili je potrošena kvota. Sačekaj malo pa pokušaj ponovo.';
      default:
        return message ?? 'Greška servera ($status). Pokušaj ponovo.';
    }
  }
}
