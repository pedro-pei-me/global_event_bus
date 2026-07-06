import 'package:flutter/material.dart';

import 'geb_debug_stats.dart';
import 'geb_debug_event_stream.dart';
import 'geb_debug_history.dart';
import 'geb_debug_listeners.dart';
import 'geb_debug_logs.dart';
import 'geb_debug_tools.dart';

class GebDebugPanel extends StatelessWidget {
  const GebDebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Global Event Bus Debug'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.deepPurple[200],
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: '统计'),
              Tab(text: '实时'),
              Tab(text: '历史'),
              Tab(text: '监听'),
              Tab(text: '日志'),
              Tab(text: '工具'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GebDebugStatsPanel(),
            GebDebugEventStream(),
            GebDebugHistoryPanel(),
            GebDebugListenerPanel(),
            GebDebugLogPanel(),
            GebDebugToolsPanel(),
          ],
        ),
      ),
    );
  }
}