import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/timeline_event.dart';

class TimeLine extends StatelessWidget {
  final List<TimelineEvent> events;

  const TimeLine({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أحداث حديثة',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Sort events with newest on top
    final sortedEvents = List<TimelineEvent>.from(events)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SizedBox(
      height: 400,
      child: Timeline.tileBuilder(
        builder: TimelineTileBuilder.fromStyle(
          contentsAlign: ContentsAlign.alternating,
          contentsBuilder: (context, index) {
            final event = sortedEvents[index];
            return _buildEventCard(context, event);
          },
          itemCount: sortedEvents.length,
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, TimelineEvent event) {
    final icon = _getEventIcon(event.type);
    final color = _getEventColor(event.type);
    final formattedTime = DateFormat('HH:mm').format(event.timestamp);
    final formattedDate = DateFormat('dd/MM/yyyy').format(event.timestamp);

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedTime,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.invoice:
        return Icons.receipt_long;
      case EventType.shipment:
        return Icons.local_shipping;
      case EventType.vault:
        return Icons.account_balance;
      case EventType.client:
        return Icons.person_add;
      case EventType.inventory:
        return Icons.inventory;
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.invoice:
        return Colors.blue;
      case EventType.shipment:
        return Colors.orange;
      case EventType.vault:
        return Colors.green;
      case EventType.client:
        return Colors.purple;
      case EventType.inventory:
        return Colors.teal;
    }
  }
}
