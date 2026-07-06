import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';
import 'advanced_example.dart';
import 'event_bus_builder_demo.dart';
import 'bloc_simple_demo.dart';

void main() {
  // 配置全局事件总线日志
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
      title: '全局事件总线示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
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
  }

  void _setupEventListeners() {
    _subscriptions = [
      // 监听计数器事件
      globalEventBus.listen<int>(
        listenerId: 'main_counter_listener',
        onEvent: (event) {
          setState(() {
            _counter = event.data;
            _message = '收到计数器事件: ${event.data} (优先级: ${event.priority.name})';
          });
        },
      ),

      // 监听用户状态事件
      globalEventBus.listen<Map<String, dynamic>>(
        listenerId: 'user_status_listener',
        onEvent: (event) {
          setState(() {
            _userStatus = event.data['status'] ?? '未知';
            _message = '用户状态更新: ${event.data['status']}';
          });
        },
      ),

      // 监听通知事件
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
    // 取消所有订阅
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _incrementCounter() {
    final newValue = _counter + 1;

    // 发送不同优先级的事件
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

    // 延迟发送欢迎通知
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
    // 启用批量模式
    globalEventBus.manager.setBatchMode(true, intervalMs: 200);

    // 快速发送多个事件
    for (int i = 1; i <= 5; i++) {
      globalEventBus.sendEvent<String>(
        type: 'notification_received',
        data: '批量通知 $i',
        priority: GebPriority.low,
      );
    }

    // 2秒后禁用批量模式
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
        title: const Text('全局事件总线示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('当前状态', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('计数器: $_counter'),
                    Text('用户状态: $_userStatus'),
                    Text('最新消息: $_message'),
                    const SizedBox(height: 8),
                    Text(
                      '事件统计: ${stats.totalEventsSent} 已发送, ${stats.totalEventsReceived} 已接收',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 操作按钮区域
            Text('事件操作', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('增加计数器'),
                ),
                ElevatedButton(
                  onPressed: _simulateUserLogin,
                  child: const Text('模拟登录'),
                ),
                ElevatedButton(
                  onPressed: _simulateUserLogout,
                  child: const Text('模拟登出'),
                ),
                ElevatedButton(
                  onPressed: _sendRandomNotification,
                  child: const Text('发送通知'),
                ),
                ElevatedButton(
                  onPressed: _sendBatchEvents,
                  child: const Text('批量事件'),
                ),
                // 添加高级示例按钮
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvancedExamplePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('高级示例'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GebBuilderDemoPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('EventBusBuilder'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BlocSimpleDemoPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('BLoC 集成'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 通知列表
            Text('最近通知', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(child: Text('暂无通知'))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(_notifications[index]),
                            subtitle: Text('第 ${index + 1} 条通知'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 统计页面
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
    // 每秒更新统计信息
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('事件统计'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('基础统计', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('总发送事件数: ${stats.totalEventsSent}'),
                    Text('总接收事件数: ${stats.totalEventsReceived}'),
                    Text('活跃监听器数: ${performanceInfo['listenerCount']}'),
                    Text('批量队列大小: ${performanceInfo['batchQueueSize']}'),
                    Text(
                      '批量模式: ${performanceInfo['batchEnabled'] ? "启用" : "禁用"}',
                    ),
                    if (stats.lastEventTime != null) Text('最后事件时间: ${stats.lastEventTime}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '事件类型统计',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (stats.eventTypeCount.isEmpty)
                      const Text('暂无事件统计')
                    else
                      ...stats.eventTypeCount.entries.map(
                        (entry) => Text('${entry.key}: ${entry.value} 次'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '监听器信息',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (globalEventBus.manager.listenerIds.isEmpty)
                      const Text('暂无活跃监听器')
                    else
                      ...globalEventBus.manager.listenerIds.map(
                        (id) => Text('• $id'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
