import 'package:flutter/material.dart';

import '../global_event_bus_api.dart';
import '../global_event_model.dart';

class GebDebugToolsPanel extends StatelessWidget {
  const GebDebugToolsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final performanceInfo = globalEventBus.performanceInfo;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '事件操作',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildToolButton(
          '发送测试事件 (String)',
          Icons.send,
          Colors.blue,
          () => globalEventBus.sendEvent<String>(
            type: 'debug_test_string',
            data: 'Test message from debug panel',
          ),
        ),
        _buildToolButton(
          '发送测试事件 (int)',
          Icons.numbers,
          Colors.green,
          () => globalEventBus.sendEvent<int>(
            type: 'debug_test_int',
            data: 42,
            priority: GebPriority.high,
          ),
        ),
        _buildToolButton(
          '发送测试事件 (Map)',
          Icons.map,
          Colors.orange,
          () => globalEventBus.sendEvent<Map<String, dynamic>>(
            type: 'debug_test_map',
            data: {'key': 'value', 'number': 123},
          ),
        ),
        _buildToolButton(
          '发送无数据事件',
          Icons.event_note,
          Colors.purple,
          () => globalEventBus.sendEventWithoutData(type: 'debug_no_data'),
        ),
        _buildToolButton(
          '发送延迟事件',
          Icons.timer,
          Colors.cyan,
          () => globalEventBus.sendEventDelayed<String>(
            type: 'debug_delayed',
            data: 'Delayed message',
            delay: const Duration(seconds: 2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '系统操作',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildToolButton(
          '清空历史记录',
          Icons.delete_sweep,
          Colors.red,
          () => globalEventBus.clearHistory(),
        ),
        _buildToolButton(
          '移除所有监听器',
          Icons.delete_forever,
          Colors.red,
          () => globalEventBus.removeAllListeners(),
        ),
        _buildToolButton(
          '清理过期监听器',
          Icons.cleaning_services,
          Colors.orange,
          () => globalEventBus.cleanupExpiredListeners(),
        ),
        const SizedBox(height: 16),
        const Text(
          '批量模式',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildToggleButton(
          '启用批量模式',
          Icons.layers,
          performanceInfo['batchEnabled'] == true,
          () => globalEventBus.setBatchMode(true),
        ),
        _buildToggleButton(
          '禁用批量模式',
          Icons.layers_clear,
          performanceInfo['batchEnabled'] != true,
          () => globalEventBus.setBatchMode(false),
        ),
        const SizedBox(height: 16),
        const Text(
          '数据导出',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildToolButton(
          '导出统计数据',
          Icons.download,
          Colors.green,
          () {
            final stats = globalEventBus.stats;
            debugPrint('=== Stats Export ===');
            debugPrint('Total sent: ${stats.totalEventsSent}');
            debugPrint('Total received: ${stats.totalEventsReceived}');
            debugPrint('Event types: ${stats.eventTypeCount}');
            debugPrint('Last event time: ${stats.lastEventTime}');
            debugPrint('=== End Export ===');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('统计数据已导出到控制台')),
            );
          },
        ),
        _buildToolButton(
          '导出历史记录',
          Icons.history,
          Colors.blue,
          () {
            final history = globalEventBus.history.all;
            debugPrint('=== History Export (${history.length} events) ===');
            for (final event in history) {
              debugPrint('${event.timestamp}: ${event.type} - ${event.priority.name}');
            }
            debugPrint('=== End Export ===');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('历史记录已导出到控制台')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, bool active, VoidCallback onPressed) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: active ? Colors.green : Colors.grey),
        title: Text(label),
        trailing: active
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.circle_outlined, color: Colors.grey),
        onTap: onPressed,
      ),
    );
  }
}
