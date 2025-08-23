import 'package:equatable/equatable.dart';

enum EventType { invoice, shipment, vault, client, inventory }

class TimelineEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final EventType type;
  final String? relatedId;
  final Map<String, dynamic>? metadata;

  const TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.relatedId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    timestamp,
    type,
    relatedId,
    metadata,
  ];

  TimelineEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    EventType? type,
    String? relatedId,
    Map<String, dynamic>? metadata,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      metadata: metadata ?? this.metadata,
    );
  }
}
