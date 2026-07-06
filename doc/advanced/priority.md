# 事件优先级

## 概述

事件优先级允许您控制事件的处理顺序。在批量模式下，高优先级事件会优先处理。

## 优先级级别

```dart
enum GebPriority {
  low,    // 低优先级
  normal, // 正常优先级（默认）
  high,   // 高优先级
}
```

## 使用方式

### 发送带优先级的事件

```dart
// 发送高优先级事件
globalEventBus.sendEvent<String>(
  eventType: 'urgent_message',
  data: '紧急通知',
  priority: GebPriority.high,
);

// 发送低优先级事件
globalEventBus.sendEvent<String>(
  eventType: 'background_task',
  data: '后台任务',
  priority: GebPriority.low,
);

// 发送正常优先级事件（默认）
globalEventBus.sendEvent<String>(
  eventType: 'normal_event',
  data: '普通事件',
);
```

### 批量模式下的优先级处理

在批量模式下，事件会按优先级排序后处理：

```dart
// 启用批量模式
globalEventBus.enableBatchMode(
  flushInterval: Duration(milliseconds: 100),
);

// 发送多个事件
globalEventBus.sendEvent<String>(
  eventType: 'task1',
  data: '低优先级任务',
  priority: GebPriority.low,
);

globalEventBus.sendEvent<String>(
  eventType: 'task2',
  data: '高优先级任务',
  priority: GebPriority.high,
);

globalEventBus.sendEvent<String>(
  eventType: 'task3',
  data: '普通任务',
  priority: GebPriority.normal,
);

// 处理顺序：task2 (high) → task3 (normal) → task1 (low)
```

## 优先级对比

| 优先级 | 处理顺序 | 适用场景 |
|--------|---------|---------|
| `high` | 最先 | 紧急事件、关键更新 |
| `normal` | 中间 | 普通业务事件 |
| `low` | 最后 | 后台任务、统计数据 |

## 最佳实践

1. **合理使用优先级** - 不要滥用高优先级，只用于真正紧急的事件
2. **避免优先级反转** - 确保低优先级事件也能被处理
3. **批量模式配合** - 优先级在批量模式下效果最明显
4. **日志查看** - 使用调试面板查看事件优先级

## 注意事项

1. 非批量模式下，优先级不影响处理顺序
2. 相同优先级的事件按发送顺序处理
3. 优先级只影响事件处理顺序，不影响事件发送