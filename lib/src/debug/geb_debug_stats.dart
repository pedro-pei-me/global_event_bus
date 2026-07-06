import 'dart:async';

import 'package:flutter/material.dart';

import '../global_event_bus_api.dart';

class GebDebugStatsPanel extends StatefulWidget {
  const GebDebugStatsPanel({super.key});

  @override
  State<GebDebugStatsPanel> createState() => _GebDebugStatsPanelState();
}

class _GebDebugStatsPanelState extends State<GebDebugStatsPanel> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = globalEventBus.stats;
    final performanceInfo = globalEventBus.performanceInfo;
    final history = globalEventBus.history;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '事件统计',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStatsCard(
          '已发送事件',
          stats.totalEventsSent.toString(),
          Colors.blue,
          Icons.send,
        ),
        _buildStatsCard(
          '已接收事件',
          stats.totalEventsReceived.toString(),
          Colors.green,
          Icons.receipt,
        ),
        _buildStatsCard(
          '活跃监听器',
          performanceInfo['listenerCount'].toString(),
          Colors.orange,
          Icons.list_alt,
        ),
        _buildStatsCard(
          '事件类型数',
          stats.eventTypeCount.length.toString(),
          Colors.purple,
          Icons.category,
        ),
        const SizedBox(height: 16),
        const Text(
          '运行状态',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStatusCard(
          '批量模式',
          performanceInfo['batchEnabled'] == true ? '启用' : '禁用',
          performanceInfo['batchEnabled'] == true ? Colors.green : Colors.grey,
          Icons.layers,
        ),
        _buildStatusCard(
          '批量队列',
          performanceInfo['batchQueueSize'].toString(),
          Colors.blue,
          Icons.queue,
        ),
        _buildStatusCard(
          '历史记录',
          history.config.enabled ? '启用 (${history.count})' : '禁用',
          history.config.enabled ? Colors.green : Colors.grey,
          Icons.history,
        ),
        if (stats.lastEventTime != null)
          _buildInfoCard(
            '最后事件时间',
            stats.lastEventTime!.toLocal().toString(),
            Icons.access_time,
          ),
        const SizedBox(height: 16),
        const Text(
          '事件类型分布',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (stats.eventTypeCount.isEmpty)
          const Center(child: Text('暂无事件统计'))
        else
          ...stats.eventTypeCount.entries.map(
            (entry) => _buildEventTypeCard(entry.key, entry.value),
          ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildEventTypeCard(String type, int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                type,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
