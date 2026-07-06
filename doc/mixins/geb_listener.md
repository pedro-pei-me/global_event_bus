# GebListener Mixin

## 概述

`GebListener` 是一个 Mixin，用于在 `StatefulWidget` 中简化事件订阅。它会自动管理订阅的生命周期，在 Widget 销毁时自动取消所有订阅。

## 使用方式

```dart
import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with GebListener {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    
    // 订阅事件
    gebSubscribe<int>(
      listenerId: 'counter_listener',
      eventType: 'counter_updated',
      onEvent: (GebEvent<int> event) {
        setState(() {
          _counter = event.data;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('计数器: $_counter');
  }

  // 无需手动取消订阅，dispose 时自动处理
}
```

## 方法说明

### gebSubscribe

订阅事件，持续监听。

```dart
StreamSubscription<GebBaseEvent> gebSubscribe<T>({
  required String listenerId,
  String? eventType,
  List<String>? eventTypes,
  required void Function(GebEvent<T> event) onEvent,
  void Function(Object error)? onError,
});
```

### gebSubscribeOnce

订阅一次性事件，触发后自动移除。

```dart
StreamSubscription<GebBaseEvent> gebSubscribeOnce<T>({
  required String listenerId,
  String? eventType,
  List<String>? eventTypes,
  required void Function(GebEvent<T> event) onEvent,
});
```

### gebUnsubscribe

根据 ID 取消单个订阅。

```dart
void gebUnsubscribe(String listenerId);
```

### gebUnsubscribeAll

取消所有订阅。

```dart
void gebUnsubscribeAll();
```

## 监听多个事件类型

```dart
gebSubscribe<String>(
  listenerId: 'multi_type_listener',
  eventTypes: ['notification', 'message'],
  onEvent: (GebEvent<String> event) {
    // 通过 event.type 区分事件类型
    if (event.type == 'notification') {
      // 处理通知
    } else {
      // 处理消息
    }
  },
);
```

## 监听无数据事件

使用 `GebNoDataListener` Mixin：

```dart
class _MyWidgetState extends State<MyWidget> with GebNoDataListener {
  @override
  void initState() {
    super.initState();
    
    gebSubscribeNoData(
      listenerId: 'logout_listener',
      eventType: 'user_logged_out',
      onEvent: () {
        // 处理登出逻辑
      },
    );
  }
}
```

## 组合使用

可以同时使用多个 Mixin：

```dart
class _MyWidgetState extends State<MyWidget> 
    with GebListener, GebNoDataListener {
  
  @override
  void initState() {
    super.initState();
    
    // 使用 GebListener
    gebSubscribe<int>(
      listenerId: 'counter_listener',
      eventType: 'counter_updated',
      onEvent: (event) => setState(() => _counter = event.data),
    );
    
    // 使用 GebNoDataListener
    gebSubscribeNoData(
      listenerId: 'refresh_listener',
      eventType: 'refresh_data',
      onEvent: () => _refreshData(),
    );
  }
}
```

## 自定义事件总线

默认使用全局单例 `globalEventBus`，可以通过重写 `eventBus` 属性使用自定义实例：

```dart
class _MyWidgetState extends State<MyWidget> with GebListener {
  final GlobalEventBus _customEventBus = GlobalEventBus();

  @override
  GlobalEventBus get eventBus => _customEventBus;

  @override
  void initState() {
    super.initState();
    gebSubscribe<int>(
      listenerId: 'custom_listener',
      eventType: 'custom_event',
      onEvent: (event) => setState(() => _value = event.data),
    );
  }
}
```

## 与 StatefulWidget 对比

| 方式 | 代码量 | 生命周期管理 | 类型安全 |
|------|--------|-------------|---------|
| `GebListener` | 少 | 自动 | ✅ |
| 手动 `listen` | 多 | 手动 | ✅ |
| `GebBuilder` | 最少 | 自动 | ✅ |

## 注意事项

1. `listenerId` 必须唯一，否则会覆盖之前的订阅
2. 泛型类型必须与发送事件时的数据类型一致
3. 无需在 `dispose()` 中手动调用 `cancel()`
4. 使用 `gebSubscribeOnce` 订阅的事件会在触发后自动移除