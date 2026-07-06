# 批量处理模式

## 概述

批量处理模式允许您将多个事件收集在一起，然后一次性处理，减少事件处理的开销，提高性能。

## 使用方式

### 启用批量模式

```dart
// 启用批量模式，每 100ms 刷新一次
globalEventBus.enableBatchMode(
  flushInterval: Duration(milliseconds: 100),
  maxBatchSize: 100,
);

// 或者使用 setBatchMode
globalEventBus.setBatchMode(
  enabled: true,
  flushInterval: Duration(milliseconds: 100),
);
```

### 禁用批量模式

```dart
globalEventBus.setBatchMode(enabled: false);
```

### 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enabled` | `bool` | `false` | 是否启用批量模式 |
| `flushInterval` | `Duration` | `50ms` | 刷新间隔 |
| `maxBatchSize` | `int` | `100` | 最大批量大小 |

## 工作原理

```
事件发送 → 事件队列 → 批量处理 → 分发到监听器
     │            │              │
     ├── flushInterval 触发      │
     └── maxBatchSize 达到      │
                                ▼
                          按优先级排序
```

## 性能对比

| 模式 | 事件处理延迟 | CPU 使用率 | 适用场景 |
|------|------------|-----------|---------|
| 普通模式 | 低（立即处理） | 高（频繁调度） | 实时性要求高 |
| 批量模式 | 中（延迟处理） | 低（批量调度） | 高频事件场景 |

## 使用示例

### 高频事件场景

```dart
// 启用批量模式
globalEventBus.enableBatchMode(
  flushInterval: Duration(milliseconds: 50),
);

// 发送高频事件
for (int i = 0; i < 100; i++) {
  globalEventBus.sendEvent<int>(
    eventType: 'data_update',
    data: i,
    priority: GebPriority.low,
  );
}

// 这些事件会被收集并一次性处理
```

### 混合优先级

```dart
globalEventBus.enableBatchMode();

// 发送多个不同优先级的事件
globalEventBus.sendEvent<String>(
  eventType: 'background',
  data: '后台任务',
  priority: GebPriority.low,
);

globalEventBus.sendEvent<String>(
  eventType: 'urgent',
  data: '紧急任务',
  priority: GebPriority.high,
);

// 紧急任务会优先处理
```

## 最佳实践

1. **调整刷新间隔** - 根据业务需求调整 `flushInterval`
2. **设置批量大小** - 根据内存和性能需求调整 `maxBatchSize`
3. **合理使用优先级** - 高优先级事件在批量模式下效果更明显
4. **监控性能** - 使用调试面板监控批量模式状态和性能
5. **适时切换** - 在需要实时性时禁用批量模式

## 注意事项

1. 批量模式会增加事件处理延迟
2. 适合高频事件场景，不适合实时性要求高的场景
3. 批量处理时会按优先级排序
4. 达到 `maxBatchSize` 或 `flushInterval` 到期时会触发处理