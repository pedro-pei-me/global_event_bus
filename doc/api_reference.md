# API 参考

## 全局实例

```dart
globalEventBus
```

全局单例实例，提供所有事件总线功能。

---

## 事件发送

### sendEvent

发送带数据的事件。

```dart
void sendEvent<T>({
  required String eventType,
  required T data,
  GebPriority priority = GebPriority.normal,
  Map<String, dynamic>? metadata,
});
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `eventType` | `String` | ✅ | 事件类型标识 |
| `data` | `T` | ✅ | 事件数据 |
| `priority` | `GebPriority` | ❌ | 事件优先级 |
| `metadata` | `Map<String, dynamic>` | ❌ | 事件元数据 |

### sendEventWithoutData

发送不带数据的事件。

```dart
void sendEventWithoutData(
  String eventType, {
  GebPriority priority = GebPriority.normal,
});
```

### sendEventDelayed

发送延迟事件。

```dart
void sendEventDelayed<T>({
  required String eventType,
  required T data,
  required Duration delay,
  GebPriority priority = GebPriority.normal,
});
```

### sendEventSafe

安全发送事件，不会抛出异常。

```dart
void sendEventSafe<T>({
  required String eventType,
  required T data,
  GebPriority priority = GebPriority.normal,
});
```

---

## 事件监听

### listen

监听事件。

```dart
StreamSubscription<GebBaseEvent> listen<T>({
  required String listenerId,
  String? eventType,
  List<String>? eventTypes,
  required void Function(GebEvent<T>) onEvent,
  void Function(Object error)? onError,
});
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `listenerId` | `String` | ✅ | 监听器唯一标识 |
| `eventType` | `String` | ❌ | 监听单个事件类型 |
| `eventTypes` | `List<String>` | ❌ | 监听多个事件类型 |
| `onEvent` | `Function` | ✅ | 事件回调 |
| `onError` | `Function` | ❌ | 错误回调 |

### listenOnce

监听一次性事件，触发后自动移除。

```dart
StreamSubscription<GebBaseEvent> listenOnce<T>({
  required String listenerId,
  String? eventType,
  List<String>? eventTypes,
  required void Function(GebEvent<T>) onEvent,
});
```

### removeListener

移除指定监听器。

```dart
void removeListener(String listenerId);
```

### removeAllListeners

移除所有监听器。

```dart
void removeAllListeners();
```

### hasListener

检查是否存在指定监听器。

```dart
bool hasListener(String listenerId);
```

---

## 日志配置

### configureLogging

配置日志。

```dart
void configureLogging(GebLogConfig config);
```

### enableDebugLogging

启用调试日志。

```dart
void enableDebugLogging();
```

### enableProductionLogging

启用生产日志。

```dart
void enableProductionLogging();
```

---

## 批量模式

### enableBatchMode

启用批量处理模式。

```dart
void enableBatchMode({
  Duration? flushInterval,
  int? maxBatchSize,
});
```

### setBatchMode

设置批量模式状态。

```dart
void setBatchMode({
  bool enabled = true,
  Duration? flushInterval,
  int? maxBatchSize,
});
```

---

## 统计与监控

### stats

获取统计信息。

```dart
GebStats get stats;
```

### listenerCount

获取监听器数量。

```dart
int get listenerCount;
```

### listenerIds

获取所有监听器 ID。

```dart
List<String> get listenerIds;
```

### performanceInfo

获取性能信息。

```dart
Map<String, dynamic> get performanceInfo;
```

---

## 调试面板

### debug.show

显示调试面板。

```dart
void debug.show(BuildContext context);
```

### debug.showFloating

显示悬浮调试按钮。

```dart
void debug.showFloating(BuildContext context);
```

### debug.panel

获取调试面板 Widget。

```dart
Widget get debug.panel;
```

---

## 核心类型

### GebEvent<T>

事件类，包含事件数据。

```dart
class GebEvent<T> extends GebBaseEvent {
  final T data;
  
  GebEvent({
    required String type,
    required this.data,
    GebPriority priority = GebPriority.normal,
    String? eventId,
    Map<String, dynamic>? metadata,
  });
}
```

### GebBaseEvent

基础事件类。

```dart
class GebBaseEvent {
  final String type;
  final GebPriority priority;
  final String eventId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
}
```

### GebPriority

事件优先级枚举。

```dart
enum GebPriority {
  low,
  normal,
  high,
}
```

### GebLogLevel

日志级别枚举。

```dart
enum GebLogLevel {
  silent,
  error,
  warning,
  info,
  debug,
}
```

### GebLogConfig

日志配置类。

```dart
class GebLogConfig {
  final GebLogLevel level;
  final bool enabled;
  final bool showTimestamp;
  final bool showEventData;
  final bool showEventId;
  final bool showListenerInfo;
  final bool showPriority;
  final String logPrefix;
  final List<String>? eventTypeFilter;
  final List<String>? listenerIdFilter;
  final void Function(String message)? customLogger;
}
```

---

## 废弃 API

以下 API 已废弃，使用新名称替代：

| 旧名称 | 新名称 |
|--------|--------|
| `GlobalEvent<T>` | `GebEvent<T>` |
| `BaseGlobalEvent` | `GebBaseEvent` |
| `EventPriority` | `GebPriority` |
| `EventLogLevel` | `GebLogLevel` |
| `GlobalEventLogConfig` | `GebLogConfig` |
| `EventStats` | `GebStats` |
| `GlobalEventManager` | `GebEventManager` |
| `EventBusListener` | `GebListener` |
| `EventBusNoDataListener` | `GebNoDataListener` |
| `sendGlobalEvent` | `sendEvent` |
| `listenGlobalEvent` | `listen` |
| `removeGlobalEventListener` | `removeListener` |