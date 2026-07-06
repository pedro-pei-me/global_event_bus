import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';
import 'advanced_example.dart';
import 'event_bus_builder_demo.dart';
import 'bloc_simple_demo.dart';
import 'listener_mixin_demo.dart';

void main() {
  globalEventBus.configureLogging(
    const GebLogConfig(
      level: GebLogLevel.debug,
      showEventData: true,
      showEventId: true,
      showListenerInfo: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Event Bus Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/geb_debug': (_) => globalEventBus.debug.panel,
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  String _message = '等待事件...';
  String _userStatus = '未登录';
  final List<String> _notifications = [];
  late List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalEventBus.debug.showFloating(context);
    });
  }

  void _setupEventListeners() {
    _subscriptions = [
      globalEventBus.listen<int>(
        listenerId: 'main_counter_listener',
        onEvent: (event) {
          setState(() {
            _counter = event.data;
            _message = '收到计数器事件: ${event.data} (优先级: ${event.priority.name})';
          });
        },
      ),
      globalEventBus.listen<Map<String, dynamic>>(
        listenerId: 'user_status_listener',
        onEvent: (event) {
          setState(() {
            _userStatus = event.data['status'] ?? '未知';
            _message = '用户状态更新: ${event.data['status']}';
          });
        },
      ),
      globalEventBus.listen<String>(
        listenerId: 'notification_listener',
        onEvent: (event) {
          setState(() {
            _notifications.insert(0, event.data);
            if (_notifications.length > 5) {
              _notifications.removeLast();
            }
            _message = '收到通知: ${event.data}';
          });
        },
      ),
    ];
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _incrementCounter() {
    final newValue = _counter + 1;
    final priority = newValue % 4 == 0
        ? GebPriority.critical
        : newValue % 3 == 0
            ? GebPriority.high
            : newValue % 2 == 0
                ? GebPriority.normal
                : GebPriority.low;

    globalEventBus.sendEvent<int>(
      type: 'counter_updated',
      data: newValue,
      priority: priority,
      metadata: {
        'source': 'main_button',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void _simulateUserLogin() {
    final users = ['张三', '李四', '王五', '赵六'];
    final randomUser = users[Random().nextInt(users.length)];

    globalEventBus.sendEvent<Map<String, dynamic>>(
      type: 'user_status_changed',
      data: {
        'status': '已登录',
        'username': randomUser,
        'loginTime': DateTime.now().toIso8601String(),
      },
      priority: GebPriority.high,
    );

    Timer(const Duration(seconds: 1), () {
      globalEventBus.sendEvent<String>(
        type: 'notification_received',
        data: '欢迎 $randomUser！',
        priority: GebPriority.normal,
      );
    });
  }

  void _simulateUserLogout() {
    globalEventBus.sendEvent<Map<String, dynamic>>(
      type: 'user_status_changed',
      data: {'status': '已登出', 'logoutTime': DateTime.now().toIso8601String()},
      priority: GebPriority.normal,
    );
  }

  void _sendRandomNotification() {
    final notifications = ['您有新消息', '系统更新完成', '数据同步成功', '任务执行完毕', '网络连接恢复'];
    final randomNotification = notifications[Random().nextInt(notifications.length)];

    globalEventBus.sendEvent<String>(
      type: 'notification_received',
      data: randomNotification,
      priority: GebPriority.low,
    );
  }

  void _sendBatchEvents() {
    globalEventBus.manager.setBatchMode(true, intervalMs: 200);
    for (int i = 1; i <= 5; i++) {
      globalEventBus.sendEvent<String>(
        type: 'notification_received',
        data: '批量通知 $i',
        priority: GebPriority.low,
      );
    }
    Timer(const Duration(seconds: 2), () {
      globalEventBus.manager.setBatchMode(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = globalEventBus.stats;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Global Event Bus Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
            tooltip: '统计信息',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              globalEventBus.debug.show(context);
            },
            tooltip: '调试面板',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(stats),
            const SizedBox(height: 20),
            _buildEventOperationSection(),
            const SizedBox(height: 20),
            _buildFeatureDemoSection(),
            const SizedBox(height: 20),
            _buildNotificationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(GebStats stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('当前状态', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    '计数器',
                    '$_counter',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    '用户状态',
                    _userStatus,
                    _userStatus == '已登录' ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最新消息',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(_message),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '事件统计: ${stats.totalEventsSent} 发送 / ${stats.totalEventsReceived} 接收',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildEventOperationSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.send, color: Colors.blue),
                const SizedBox(width: 8),
                Text('事件操作', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton('增加计数器', Icons.add, Colors.blue, _incrementCounter),
                _buildActionButton('模拟登录', Icons.login, Colors.green, _simulateUserLogin),
                _buildActionButton('模拟登出', Icons.logout, Colors.orange, _simulateUserLogout),
                _buildActionButton('发送通知', Icons.notifications, Colors.purple, _sendRandomNotification),
                _buildActionButton('批量事件', Icons.layers, Colors.cyan, _sendBatchEvents),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildFeatureDemoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.featured_play_list, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('新功能演示', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '点击下方按钮查看各功能的详细演示',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildFeatureCard(
                  'GebBuilder',
                  '响应式 Widget',
                  Icons.widgets,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GebBuilderDemoPage()),
                  ),
                ),
                _buildFeatureCard(
                  'GebListener',
                  '事件监听 Mixin',
                  Icons.add_circle,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListenerMixinDemoPage()),
                  ),
                ),
                _buildFeatureCard(
                  'BLoC 集成',
                  '状态管理桥接',
                  Icons.connect_without_contact,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BlocSimpleDemoPage()),
                  ),
                ),
                _buildFeatureCard(
                  '高级示例',
                  '完整业务场景',
                  Icons.apps,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdvancedExamplePage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.message, color: Colors.purple),
                const SizedBox(width: 8),
                Text('最近通知', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            _notifications.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('暂无通知，请发送一些事件'),
                    ),
                  )
                : Column(
                    children: _notifications.map((notification) {
                      return ListTile(
                        leading: const Icon(Icons.notifications, color: Colors.purple),
                        title: Text(notification),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final performanceInfo = globalEventBus.manager.performanceInfo;
    final history = globalEventBus.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('事件统计'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard('基础统计', Icons.data_usage, {
              '总发送事件数': stats.totalEventsSent.toString(),
              '总接收事件数': stats.totalEventsReceived.toString(),
              '活跃监听器数': performanceInfo['listenerCount'].toString(),
              '事件类型数': stats.eventTypeCount.length.toString(),
            }),
            const SizedBox(height: 16),
            _buildStatCard('运行状态', Icons.settings, {
              '批量模式': performanceInfo['batchEnabled'] == true ? '启用' : '禁用',
              '批量队列': performanceInfo['batchQueueSize'].toString(),
              '历史记录': history.config.enabled ? '启用 (${history.count})' : '禁用',
              '最后事件': stats.lastEventTime != null ? stats.lastEventTime!.toLocal().toString() : '无',
            }),
            const SizedBox(height: 16),
            _buildStatCard('事件类型分布', Icons.pie_chart,
                Map.fromEntries(stats.eventTypeCount.entries.map((e) => MapEntry(e.key, e.value.toString())))),
            const SizedBox(height: 16),
            _buildStatCard('活跃监听器', Icons.list_alt,
                Map.fromEntries(globalEventBus.manager.listenerIds.map((id) => MapEntry(id, '')))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Map<String, String> items) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Center(child: Text('暂无数据'))
            else
              ...items.entries.map((entry) {
                if (entry.value.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• ${entry.key}'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(entry.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
