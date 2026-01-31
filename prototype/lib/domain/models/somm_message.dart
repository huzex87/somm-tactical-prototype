import 'dart:convert';

class SommMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String payload; // Encrypted Base64
  final DateTime timestamp;
  final int ttl;
  final List<String> relayHops;

  const SommMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.payload,
    required this.timestamp,
    this.ttl = 5,
    this.relayHops = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'ttl': ttl,
      'relay_hops': relayHops,
    };
  }

  factory SommMessage.fromJson(Map<String, dynamic> json) {
    return SommMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      recipientId: json['recipient_id'] as String,
      payload: json['payload'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: json['ttl'] as int,
      relayHops: List<String>.from(json['relay_hops'] as List),
    );
  }

  SommMessage copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? payload,
    DateTime? timestamp,
    int? ttl,
    List<String>? relayHops,
  }) {
    return SommMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      ttl: ttl ?? this.ttl,
      relayHops: relayHops ?? this.relayHops,
    );
  }
}
