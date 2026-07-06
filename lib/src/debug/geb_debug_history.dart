import 'package:flutter/material.dart';

import '../global_event_bus_api.dart';
import '../global_event_model.dart';

class GebDebugHistoryPanel extends StatefulWidget {
  const GebDebugHistoryPanel({super.key});

  @override
  State<GebDebugHistoryPanel> createState() => _GebDebugHistoryPanelState();
}

class _GebDebugHistoryPanelState extends State<GebDebugHistoryPanel> {
  List<GebBaseEvent> _events = [];
  String _filterType = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      if (_filterType.isEmpty) {
        _events = globalEventBus.history.allReversed.toList();
      } else {
        _events = globalEventBus.history.getByType(_filterType).reversed.toList();
      }
    });
  }

  void _clearHistory() {
    globalEventBus.clearHistory();
    _loadEvents();
  }

  List<String> get _eventTypes => globalEventBus.eventTypes;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '事件类型',
                        border: OutlineInputBorder(),
                      ),
                      value: _filterType.isEmpty ? null : _filterType,
                      items: [
                        const DropdownMenuItem(value: '', child: Text('全部')),
                        ..._eventTypes.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterType = value ?? '';
                          _loadEvents();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _clearHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('清空'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '共 ${_events.length} 条记录 (最大 ${globalEventBus.history.config.maxHistorySize})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: _events.isEmpty
              ? const Center(child: Text('暂无历史记录'))
              : ListView.builder(
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
                                event.priority.name.toUpperCase(),
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
                                if (event is GebEvent) _buildDetailRow('数据', event.data.toString()),
                                if (event.metadata != null) _buildDetailRow('元数据', event.metadata.toString()),
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
