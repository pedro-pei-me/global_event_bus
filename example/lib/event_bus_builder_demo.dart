import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';

class GebBuilderDemoPage extends StatefulWidget {
  const GebBuilderDemoPage({super.key});

  @override
  State<GebBuilderDemoPage> createState() => _GebBuilderDemoPageState();
}

class _GebBuilderDemoPageState extends State<GebBuilderDemoPage> {
  bool _useHistory = true;
  String? _initialMessage;
  int _messageCount = 0;

  void _sendMessage() {
    final messages = [
      'Hello from GebBuilder!',
      '实时更新的消息',
      '响应式编程真方便',
      'Flutter 太棒了',
      '事件驱动架构',
      '解耦通信的艺术',
      '类型安全的力量',
      'Dart Stream 很强大',
    ];

    final randomMessage = messages[Random().nextInt(messages.length)];

    globalEventBus.sendEvent<String>(
      type: 'builder_demo_message',
      data: '$randomMessage (${_messageCount + 1})',
      priority: GebPriority.normal,
      metadata: {'timestamp': DateTime.now().toIso8601String()},
    );

    setState(() {
      _messageCount++;
    });
  }

  void _sendStatusUpdate() {
    final statuses = [
      {'status': '在线', 'color': Colors.green},
      {'status': '忙碌', 'color': Colors.orange},
      {'status': '离线', 'color': Colors.red},
      {'status': '请勿打扰', 'color': Colors.purple},
    ];

    final randomStatus = statuses[Random().nextInt(statuses.length)];

    globalEventBus.sendEvent<Map<String, dynamic>>(
      type: 'builder_demo_status',
      data: randomStatus,
      priority: GebPriority.high,
    );
  }

  void _sendCounterUpdate() {
    globalEventBus.sendEvent<int>(
      type: 'builder_demo_counter',
      data: Random().nextInt(100),
      priority: GebPriority.normal,
    );
  }

  void _clearHistory() {
    globalEventBus.clearHistory();
    setState(() {
      _messageCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GebBuilder 演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
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
                    Text(
                      '配置选项',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _useHistory,
                          onChanged: (value) {
                            setState(() {
                              _useHistory = value ?? true;
                            });
                          },
                        ),
                        const Text('从历史记录获取初始数据'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: '自定义初始消息（可选）',
                        hintText: '输入初始消息...',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _initialMessage = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _clearHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[100],
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('清空历史记录'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '演示区域',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. 基础用法 - 字符串消息',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          GebBuilder<String>(
                            eventType: 'builder_demo_message',
                            useHistoryForInitialData: _useHistory,
                            initialData: _initialMessage,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('错误: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Text('等待消息...');
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '事件ID: ${snapshot.event?.eventId}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '时间: ${snapshot.event?.timestamp}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2. 复杂数据 - 用户状态',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          GebBuilder<Map<String, dynamic>>(
                            eventType: 'builder_demo_status',
                            useHistoryForInitialData: _useHistory,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text('等待状态更新...');
                              }
                              final data = snapshot.data!;
                              final status = data['status'] as String;
                              final color = data['color'] as Color;

                              return Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '用户状态: $status',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '3. 数值类型 - 随机计数器',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          GebBuilder<int>(
                            eventType: 'builder_demo_counter',
                            useHistoryForInitialData: _useHistory,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text('等待计数...');
                              }
                              return Column(
                                children: [
                                  Text(
                                    snapshot.data.toString(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  Text(
                                    '优先级: ${snapshot.event?.priority.name}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4. 多事件类型监听',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    GebBuilder<String>(
                      eventTypes: const ['builder_demo_message', 'user_welcome'],
                      useHistoryForInitialData: _useHistory,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('等待任意事件...');
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '收到事件: ${snapshot.data}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '事件类型: ${snapshot.event?.type}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '操作按钮',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('发送消息'),
                ),
                ElevatedButton(
                  onPressed: _sendStatusUpdate,
                  child: const Text('更新状态'),
                ),
                ElevatedButton(
                  onPressed: _sendCounterUpdate,
                  child: const Text('随机计数'),
                ),
                ElevatedButton(
                  onPressed: () {
                    globalEventBus.sendEvent<String>(
                      type: 'user_welcome',
                      data: '欢迎来到 GebBuilder 演示！',
                    );
                  },
                  child: const Text('发送欢迎事件'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Timer.periodic(const Duration(seconds: 1), (timer) {
                      _sendMessage();
                      if (timer.tick >= 5) {
                        timer.cancel();
                      }
                    });
                  },
                  child: const Text('定时发送(5次)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '历史记录查询',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('消息历史数量: ${globalEventBus.history.getByType('builder_demo_message').length}'),
                              Text('状态历史数量: ${globalEventBus.history.getByType('builder_demo_status').length}'),
                              Text('计数器历史数量: ${globalEventBus.history.getByType('builder_demo_counter').length}'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final recentEvents = globalEventBus.getRecentEvents(count: 5);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('最近5个事件'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: recentEvents
                                      .map((event) => ListTile(
                                            title: Text(event.type),
                                            subtitle: Text(event is GebEvent ? '数据: ${event.data}' : ''),
                                          ))
                                      .toList(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('关闭'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('查看最近事件'),
                        ),
                      ],
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
