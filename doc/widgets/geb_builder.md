# GebBuilder Widget

## 概述

`GebBuilder` 是一个响应式 Widget，用于监听事件总线并自动更新 UI。它会在收到匹配事件时自动重建子 Widget。

## 使用方式

```dart
GebBuilder<int>(
  eventType: 'counter_updated',
  builder: (context, event) {
    return Text('计数器: ${event?.data ?? 0}');
  },
);
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return GebBuilder<int>(
      eventType: 'counter_updated',
      initialData: 0,
      builder: (context, event) {
        return Center(
          child: Text(
            '计数器: ${event?.data ?? 0}',
            style: const TextStyle(fontSize: 24),
          ),
        );
      },
    );
  }
}

// 在其他地方发送事件
globalEventBus.sendEvent<int>(
  eventType: 'counter_updated',
  data: 42,
);
```

## 属性说明

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `eventType` | `String` | ✅ | 要监听的事件类型 |
| `builder` | `Widget Function(BuildContext, GebEvent<T>?)` | ✅ | 构建函数，接收事件数据 |
| `initialData` | `T` | ❌ | 初始数据 |
| `listenerId` | `String` | ❌ | 自定义监听器 ID |
| `onEvent` | `void Function(GebEvent<T>)` | ❌ | 事件回调（额外处理） |

## 多个事件类型

```dart
GebBuilder<int>(
  eventTypes: ['counter_increment', 'counter_decrement'],
  builder: (context, event) {
    if (event?.type == 'counter_increment') {
      return Text('增加: ${event?.data}');
    } else {
      return Text('减少: ${event?.data}');
    }
  },
);
```

## 嵌套使用

```dart
Column(
  children: [
    GebBuilder<int>(
      eventType: 'counter_updated',
      builder: (context, event) => Text('计数器: ${event?.data}'),
    ),
    GebBuilder<String>(
      eventType: 'message_received',
      builder: (context, event) => Text('消息: ${event?.data}'),
    ),
  ],
);
```

## 与 StatefulWidget 对比

| 方式 | 生命周期管理 | 代码复杂度 | 适用场景 |
|------|------------|-----------|---------|
| `GebBuilder` | 自动管理 | 低 | 简单的事件驱动 UI |
| `StatefulWidget` + `listen` | 手动管理 | 高 | 需要复杂逻辑处理 |
| `GebListener` Mixin | 自动管理 | 中 | 中等复杂度场景 |

## 注意事项

1. `GebBuilder` 会在收到事件时重建整个子 Widget
2. 如果子 Widget 较大，考虑使用 `ValueListenableBuilder` 或拆分组件
3. 避免在 `builder` 中执行耗时操作