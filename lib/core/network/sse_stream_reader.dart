import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

abstract class SseEvent {
  const SseEvent();
}

class SseStatusEvent extends SseEvent {
  final String status;
  final String? message;
  const SseStatusEvent(this.status, {this.message});
}

class SseThinkingEvent extends SseEvent {
  final String thought;
  final int? elapsedSeconds;
  final String? step;
  const SseThinkingEvent(this.thought, {this.elapsedSeconds, this.step});
}

class SseSearchEvent extends SseEvent {
  final String query;
  final List<SearchCitation> results;
  const SseSearchEvent(this.query, this.results);
}

class SearchCitation {
  final String title;
  final String url;
  final String? snippet;
  final String? favicon;

  SearchCitation({
    required this.title,
    required this.url,
    this.snippet,
    this.favicon,
  });

  factory SearchCitation.fromJson(Map<String, dynamic> json) {
    return SearchCitation(
      title: json['title'] as String? ?? 'Citation',
      url: json['url'] as String? ?? '',
      snippet: json['snippet'] as String?,
      favicon: json['favicon'] as String?,
    );
  }
}

class SseTokenEvent extends SseEvent {
  final String token;
  const SseTokenEvent(this.token);
}

class SseUiEvent extends SseEvent {
  final String type;
  final Map<String, dynamic> props;
  const SseUiEvent({required this.type, required this.props});
}

class SseCustomKeyMetaEvent extends SseEvent {
  final bool isByok;
  final String? provider;
  final String? model;
  const SseCustomKeyMetaEvent({required this.isByok, this.provider, this.model});
}

class SseEndEvent extends SseEvent {
  final String? messageId;
  final String? conversationId;
  final Map<String, dynamic>? metadata;
  const SseEndEvent({this.messageId, this.conversationId, this.metadata});
}

class SseErrorEvent extends SseEvent {
  final String errorCode;
  final String message;
  const SseErrorEvent({required this.errorCode, required this.message});
}

class SseUnknownEvent extends SseEvent {
  final String raw;
  const SseUnknownEvent(this.raw);
}

class SseStreamReader {
  /// Parses a raw stream of Uint8List bytes from Dio ResponseBody into SseEvents
  static Stream<SseEvent> parseStream(Stream<Uint8List> byteStream) async* {
    String buffer = '';

    await for (final chunk in byteStream) {
      final text = utf8.decode(chunk, allowMalformed: true);
      buffer += text;

      while (buffer.contains('\n\n')) {
        final delimiterIndex = buffer.indexOf('\n\n');
        final rawMessage = buffer.substring(0, delimiterIndex).trim();
        buffer = buffer.substring(delimiterIndex + 2);

        if (rawMessage.isEmpty) continue;

        final lines = rawMessage.split('\n');
        String dataPayload = '';

        for (final line in lines) {
          if (line.startsWith('data:')) {
            final content = line.substring(5).trim();
            dataPayload += (dataPayload.isEmpty ? '' : '\n') + content;
          }
        }

        if (dataPayload.isNotEmpty) {
          if (dataPayload == '[DONE]') {
            yield const SseEndEvent();
            continue;
          }

          try {
            final dynamic decoded = jsonDecode(dataPayload);
            if (decoded is Map<String, dynamic>) {
              yield _mapJsonToEvent(decoded);
            } else if (decoded is String) {
              yield SseTokenEvent(decoded);
            }
          } catch (_) {
            // If not JSON, it could be a raw text token or event
            yield SseTokenEvent(dataPayload);
          }
        }
      }
    }

    // Process leftover buffer if any
    if (buffer.trim().isNotEmpty) {
      try {
        final trimmed = buffer.trim();
        if (trimmed.startsWith('data:')) {
          final payload = trimmed.substring(5).trim();
          final dynamic decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            yield _mapJsonToEvent(decoded);
          }
        }
      } catch (_) {}
    }
  }

  static SseEvent _mapJsonToEvent(Map<String, dynamic> json) {
    final type = (json['type'] ?? json['event']) as String?;

    if (type == null) {
      if (json.containsKey('token') || json.containsKey('content')) {
        return SseTokenEvent((json['token'] ?? json['content'])?.toString() ?? '');
      }
      return SseUnknownEvent(jsonEncode(json));
    }

    switch (type.toLowerCase()) {
      case 'status':
        return SseStatusEvent(
          json['status'] as String? ?? 'Processing...',
          message: json['message'] as String?,
        );

      case 'thinking':
        return SseThinkingEvent(
          json['thought'] as String? ?? json['content'] as String? ?? '',
          elapsedSeconds: json['elapsed_seconds'] as int?,
          step: json['step'] as String?,
        );

      case 'search':
        final list = (json['searchResults'] ?? json['results'] ?? []) as List;
        final citations = list
            .map((item) => SearchCitation.fromJson(item as Map<String, dynamic>))
            .toList();
        return SseSearchEvent(json['query'] as String? ?? '', citations);

      case 'token':
      case 'text':
        return SseTokenEvent(json['token'] as String? ?? json['content'] as String? ?? '');

      case 'ui':
        final uiObj = (json['ui'] is Map<String, dynamic>)
            ? (json['ui'] as Map<String, dynamic>)
            : json;
        return SseUiEvent(
          type: uiObj['type'] as String? ??
              json['ui_type'] as String? ??
              json['name'] as String? ??
              'card',
          props: (uiObj['props'] as Map<String, dynamic>?) ??
              (json['props'] as Map<String, dynamic>?) ??
              {},
        );

      case 'custom_key_meta':
      case 'key_meta':
        return SseCustomKeyMetaEvent(
          isByok: json['is_byok'] as bool? ?? false,
          provider: json['provider'] as String?,
          model: json['model'] as String?,
        );

      case 'end':
      case 'done':
        return SseEndEvent(
          messageId: json['message_id'] as String?,
          conversationId: json['conversation_id'] as String?,
          metadata: json['metadata'] as Map<String, dynamic>?,
        );

      case 'error':
        return SseErrorEvent(
          errorCode: json['error_code'] as String? ?? 'UNKNOWN_ERROR',
          message: json['message'] as String? ?? 'An unexpected error occurred.',
        );

      default:
        return SseUnknownEvent(jsonEncode(json));
    }
  }
}
