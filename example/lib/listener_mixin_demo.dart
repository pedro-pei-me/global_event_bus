import 'dart:math';

import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';

class ListenerMixinDemoPage extends StatelessWidget {
  const ListenerMixinDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GebListener Mixin 演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildIntroCard(),
            const SizedBox(height: 20),
            _buildFeatureCard(
              '自动订阅管理',
              'GebListener 会在 Widget 初始化时自动订阅事件，在 dispose 时自动取消所有订阅，无需手动管理生命周期。',
              Icons.autorenew,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              '类型安全',
              '支持泛型类型订阅，可以精确监听特定类型的事件数据，编译时类型检查。',
              Icons.security,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              '多种订阅方式',
              '支持 gebSubscribe() 持续订阅和 gebSubscribeOnce() 一次性订阅，满足不同场景需求。',
              Icons.layers,
              Colors.purple,
            ),
            const SizedBox(height: 20),
            const EventCounterWidget(),
            const SizedBox(height: 20),
            const UserStatusWidget(),
            const SizedBox(height: 20),
            const NotificationWidget(),
            const SizedBox(height: 20),
            _buildActionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.code, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 12),
            const Text(
              'GebListener Mixin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '使用 Mixin 简化事件订阅，自动管理订阅生命周期，无需手动取消订阅。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''class _MyWidgetState extends State<MyWidget> with GebListener {
  @override
  void initState() {
    super.initState();
    gebSubscribe<String>(
      listenerId: 'my_listener',
      eventType: 'message',
      onEvent: (event) {
        setState(() { /* 更新UI */ });
      },
    );
  }
  // dispose 时自动取消所有订阅
}''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildActionSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '发送测试事件',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    globalEventBus.sendEvent<int>(
                      type: 'mixin_counter',
                      data: Random().nextInt(100),
                      priority: GebPriority.high,
                    );
                  },
                  child: const Text('发送随机计数器'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final users = ['张三', '李四', '王五'];
                    globalEventBus.sendEvent<Map<String, dynamic>>(
                      type: 'mixin_user',
                      data: {
                        'name': users[Random().nextInt(users.length)],
                        'status': 'online',
                      },
                    );
                  },
                  child: const Text('发送用户状态'),
                ),
                ElevatedButton(
                  onPressed: () {
                    globalEventBus.sendEvent<String>(
                      type: 'mixin_notification',
                      data: '这是一条测试通知 ${DateTime.now().second}',
                    );
                  },
                  child: const Text('发送通知'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EventCounterWidget extends StatefulWidget {
  const EventCounterWidget({super.key});

  @override
  State<EventCounterWidget> createState() => _EventCounterWidgetState();
}

class _EventCounterWidgetState extends State<EventCounterWidget> with GebListener {
  int _count = 0;
  String _lastValue = '-';

  @override
  void initState() {
    super.initState();
    gebSubscribe<int>(
      listenerId: 'mixin_counter_listener',
      eventType: 'mixin_counter',
      onEvent: (GebEvent<int> event) {
        setState(() {
          _count++;
          _lastValue = event.data.toString();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.numbers, color: Colors.blue),
                SizedBox(width: 8),
                Text('事件计数器', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('接收次数', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('$_count', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                Column(
                  children: [
                    const Text('最后值', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(_lastValue, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserStatusWidget extends StatefulWidget {
  const UserStatusWidget({super.key});

  @override
  State<UserStatusWidget> createState() => _UserStatusWidgetState();
}

class _UserStatusWidgetState extends State<UserStatusWidget> with GebListener {
  String _userName = '未设置';
  String _status = 'offline';

  @override
  void initState() {
    super.initState();
    gebSubscribe<Map<String, dynamic>>(
      listenerId: 'mixin_user_listener',
      eventType: 'mixin_user',
      onEvent: (GebEvent<Map<String, dynamic>> event) {
        setState(() {
          _userName = event.data['name'] ?? '未知';
          _status = event.data['status'] ?? 'offline';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.person, color: Colors.green),
                SizedBox(width: 8),
                Text('用户状态', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _status == 'online' ? Colors.green : Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _status == 'online' ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(_status == 'online' ? '在线' : '离线'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> with GebListener {
  final List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    gebSubscribe<String>(
      listenerId: 'mixin_notification_listener',
      eventType: 'mixin_notification',
      onEvent: (GebEvent<String> event) {
        setState(() {
          _notifications.insert(0, event.data);
          if (_notifications.length > 5) {
            _notifications.removeLast();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.notifications, color: Colors.purple),
                SizedBox(width: 8),
                Text('通知列表', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _notifications.isEmpty
                ? const Center(child: Text('暂无通知'))
                : Column(
                    children: _notifications.map((notification) {
                      return ListTile(
                        leading: const Icon(Icons.message, size: 16, color: Colors.purple),
                        title: Text(notification),
                        dense: true,
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}