import 'dart:async';

import 'package:flutter/material.dart';

import '../global_event_bus_api.dart';
import '../global_event_model.dart';

class GebDebugEventStream extends StatefulWidget {
  const GebDebugEventStream({super.key});

  @override
  State<GebDebugEventStream> createState() => _GebDebugEventStreamState();
}

class _GebDebugEventStreamState extends State<GebDebugEventStream> {
  final List<GebBaseEvent> _events = [];
  StreamSubscription<GebBaseEvent>? _subscription;
  bool _isPaused = false;
  final ScrollController _scrollController = ScrollController();

  static const int maxEvents = 100;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribe() {
    _subscription = globalEventBus.listen<dynamic>(
      listenerId: 'debug_event_stream',
      onEvent: (GebEvent<dynamic> event) {
        if (_isPaused) return;
        
        setState(() {
          _events.insert(0, event);
          while (_events.length > maxEvents) {
            _events.removeLast();
          }
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(0);
        });
      },
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _clearEvents() {
    setState(() {
      _events.clear();
    });
  }

  Color _getPriorityColor(GebPriority priority) {
    switch (priority) {
      case GebPriority.critical:
        return Colors.red;
      case GebPriority.high:
        return Colors.orange;
      case GebPriority.normal:
        return Colors.blue;
      case GebPriority.low:
        return Colors.grey;
    }
  }

  String _getPriorityText(GebPriority priority) {
    switch (priority) {
      case GebPriority.critical:
        return 'CRITICAL';
      case GebPriority.high:
        return 'HIGH';
      case GebPriority.normal:
        return 'NORMAL';
      case GebPriority.low:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _togglePause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPaused ? Colors.green : Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: Text(_isPaused ? '继续' : '暂停'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _clearEvents,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('清空'),
              ),
              const SizedBox(width: 8),
              Text('共 ${_events.length} 条'),
            ],
          ),
        ),
        Expanded(
          child: _events.isEmpty
              ? const Center(child: Text('等待事件...'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(event.priority).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getPriorityText(event.priority),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(event.priority),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.type,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          event.timestamp.toLocal().toString().split('.').first,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('事件ID', event.eventId),
                                if (event is GebEvent)
                                  _buildDetailRow('数据', event.data.toString()),
                                if (event.metadata != null)
                                  _buildDetailRow('元数据', event.metadata.toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}