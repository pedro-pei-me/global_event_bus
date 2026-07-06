# 快速开始

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  global_event_bus: ^1.2.0
```

然后运行：

```bash
flutter pub get
```

## 基本使用

### 发送事件

```dart
import 'package:global_event_bus/global_event_bus.dart';

// 发送带数据的事件
globalEventBus.sendEvent<int>(
  eventType: 'counter_updated',
  data: 42,
);

// 发送不带数据的事件
globalEventBus.sendEventWithoutData('user_logged_in');

// 发送延迟事件
globalEventBus.sendEventDelayed<String>(
  eventType: 'delayed_message',
  data: 'Hello',
  delay: Duration(seconds: 2),
);
```

### 监听事件

```dart
// 监听事件
final subscription = globalEventBus.listen<int>(
  listenerId: 'counter_listener',
  eventType: 'counter_updated',
  onEvent: (GebEvent<int> event) {
    print('收到事件: ${event.data}');
  },
);

// 监听多个事件类型
globalEventBus.listen<String>(
  listenerId: 'multi_listener',
  eventTypes: ['notification', 'message'],
  onEvent: (GebEvent<String> event) {
    print('收到 ${event.type}: ${event.data}');
  },
);

// 监听一次性事件
globalEventBus.listenOnce<String>(
  listenerId: 'welcome_listener',
  eventType: 'user_welcome',
  onEvent: (GebEvent<String> event) {
    print('欢迎: ${event.data}');
  },
);
```

### 取消监听

```dart
// 取消单个监听器
globalEventBus.removeListener('counter_listener');

// 取消所有监听器
globalEventBus.removeAllListeners();

// 取消订阅
subscription.cancel();
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Event Bus Demo')),
        body: const Center(
          child: CounterWidget(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            globalEventBus.sendEvent<int>(
              eventType: 'counter_increment',
              data: 1,
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = globalEventBus.listen<int>(
      listenerId: 'counter_widget',
      eventType: 'counter_increment',
      onEvent: (event) {
        setState(() {
          _counter += event.data;
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('计数器: $_counter');
  }
}
```

## 下一步

- [API 参考](api_reference.md) - 了解完整的 API
- [GebBuilder Widget](widgets/geb_builder.md) - 响应式 Widget
- [GebListener Mixin](mixins/geb_listener.md) - 简化事件订阅
- [调试面板](widgets/debug_panel.md) - 开发调试工具