# 🚀 Global Event Bus - 全局事件总线

<div align="center">
  <img src="assets/icons/animated_logo.svg" alt="Global Event Bus Logo" width="400" height="200">
</div>

[![pub package](https://img.shields.io/pub/v/global_event_bus.svg)](https://pub.dev/packages/global_event_bus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个高性能、类型安全的 Flutter 全局事件分发系统，用于在应用程序的不同模块之间进行解耦通信。采用观察者模式和流式处理架构，支持事件优先级、批量处理、延迟发送、统计监控、响应式 Widget、BLoC 集成等高级功能。

## ✨ 核心特性

### 🔒 类型安全

- 基于泛型的类型安全事件系统
- 编译时类型检查，避免运行时错误
- 自动类型推断，提升开发体验

### ⚡ 高性能

- 基于 Dart Stream 的高效事件分发
- 支持批量处理模式，优化高频事件场景
- 内置事件统计和性能监控

### 🎯 事件优先级

- 四级优先级系统：critical、high、normal、low
- 高优先级事件优先处理
- 适用于不同业务场景的事件分级

### 📊 完善的日志系统

- 多级别日志配置（debug、info、warning、error、none）
- 可配置的日志输出格式
- 支持自定义日志处理器
- 事件类型和监听器过滤

### 🔧 灵活的监听方式

- 类型监听：只监听特定类型的事件
- 一次性监听：监听一次后自动移除
- 多类型监听：同时监听多种事件类型
- 延迟发送：支持延迟指定时间后发送事件

### 📈 统计监控

- 实时事件统计
- 发送/接收计数
- 事件类型分布统计
- 性能监控数据

### 🎨 响应式 Widget

- **GebBuilder**: 类似 StreamBuilder 的响应式 Widget
- 自动管理订阅生命周期
- 支持从历史记录获取初始数据

### 🔄 BLoC 集成

- **GebBlocBridge**: BLoC 与事件总线的双向桥接器
- **GebBlocMixin**: 在 BLoC 类中直接集成事件总线
- **GebBlocMapper**: 事件映射工具类

### 📚 事件历史记录

- **GebHistory**: 事件历史记录管理器
- 支持按类型、数量查询历史事件
- 可配置最大记录数和启用/禁用

## 🏗️ 核心架构

```plantext
┌───────────────────────────────────────┐
│ Global Event Bus                      │
├───────────────────────────────────────┤
│ GlobalEventManager (单例事件管理器)     │
│ ├── 事件发送与分发                      │
│ ├── 监听器管理                         │
│ ├── 批量处理                           │
│ └── 统计监控                           │
├───────────────────────────────────────┤
│ BaseGlobalEvent (事件基类)             │
│ ├── 事件类型标识                        │
│ ├── 时间戳                             │
│ ├── 优先级                             │
│ └── 元数据                             │
├───────────────────────────────────────┤
│ GlobalEvent(泛型事件类)                 │
│ └── 类型安全的数据传递                   │
├───────────────────────────────────────┤
│ GlobalEventLogger (日志系统)           │
│ ├── 多级别日志                         │
│ ├── 可配置输出格式                      │
│ └── 自定义处理器                        │
└───────────────────────────────────────┘
```

## 📦 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  global_event_bus: <latest_version>
```

然后运行：

```zsh
flutter pub get
```

## 🚀 快速开始

### 1. 导入包

```dart
import 'package:global_event_bus/global_event_bus.dart';
```

### 2. 配置日志（可选）

```dart
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

  runApp(MyApp());
}
```

### 3. 发送事件

```dart
// 发送简单事件
globalEventBus.sendEvent<String>(
  type: 'user_message',
  data: 'Hello, World!',
);

// 发送带优先级的事件
globalEventBus.sendEvent<Map<String, dynamic>>(
  type: 'user_login',
  data: {
    'userId': '12345',
    'username': 'john_doe',
    'loginTime': DateTime.now().toIso8601String(),
  },
  priority: GebPriority.high,
);

// 延迟发送事件
globalEventBus.sendEventDelayed<String>(
  type: 'delayed_notification',
  data: '这是一个延迟消息',
  delay: Duration(milliseconds: 3000), // 3秒后发送
);

// 发送无数据事件
globalEventBus.sendEventWithoutData(type: 'app_started');
```

### 4. 监听事件

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<GebBaseEvent> _subscription;

  @override
  void initState() {
    super.initState();

    // 监听特定类型的事件
    _subscription = globalEventBus.listen<String>(
      listenerId: 'my_widget_listener',
      onEvent: (GebEvent<String> event) {
        print('收到事件: ${event.type}, 数据: ${event.data}');
        // 处理事件数据
        setState(() {
          // 更新UI
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // 取消订阅
    super.dispose();
  }
}
```

### 5. 使用 GebBuilder（推荐）

```dart
// 使用响应式 Widget 监听事件，自动管理生命周期
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GebBuilder<int>(
      eventType: 'counter_updated',
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('计数器: 0');
        }
        return Text('计数器: ${snapshot.data}');
      },
    );
  }
}
```

### 6. 使用 GebListener Mixin

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with GebListener {
  String _message = '等待事件...';

  @override
  void initState() {
    super.initState();

    // 使用 Mixin 方法订阅事件
    gebSubscribe<String>(
      listenerId: 'message_listener',
      eventType: 'user_message',
      onEvent: (GebEvent<String> event) {
        setState(() {
          _message = event.data;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(_message);
  }

  // dispose 时自动取消所有订阅，无需手动处理
}
```

### API 参数说明

#### 事件发送方法

**sendEvent<T>** - 发送带数据的事件

| 参数名   | 类型                  | 必需 | 默认值             | 说明           |
| -------- | --------------------- | ---- | ------------------ | -------------- |
| type     | String                | ✅   | -                  | 事件类型标识符 |
| data     | T                     | ✅   | -                  | 事件携带的数据 |
| priority | GebPriority           | ❌   | GebPriority.normal | 事件优先级     |
| metadata | Map<String, dynamic>? | ❌   | null               | 事件元数据     |

**sendEventWithoutData** - 发送无数据事件

| 参数名   | 类型                  | 必需 | 默认值             | 说明           |
| -------- | --------------------- | ---- | ------------------ | -------------- |
| type     | String                | ✅   | -                  | 事件类型标识符 |
| priority | GebPriority           | ❌   | GebPriority.normal | 事件优先级     |
| metadata | Map<String, dynamic>? | ❌   | null               | 事件元数据     |

**sendEventSafe<T>** - 安全发送事件（不抛出异常）

| 参数名   | 类型                  | 必需 | 默认值             | 说明           |
| -------- | --------------------- | ---- | ------------------ | -------------- |
| type     | String                | ✅   | -                  | 事件类型标识符 |
| data     | T                     | ✅   | -                  | 事件携带的数据 |
| priority | GebPriority           | ❌   | GebPriority.normal | 事件优先级     |
| metadata | Map<String, dynamic>? | ❌   | null               | 事件元数据     |

**sendEventDelayed<T>** - 延迟发送事件

| 参数名   | 类型                  | 必需 | 默认值             | 说明           |
| -------- | --------------------- | ---- | ------------------ | -------------- |
| type     | String                | ✅   | -                  | 事件类型标识符 |
| data     | T                     | ✅   | -                  | 事件携带的数据 |
| delay    | Duration              | ✅   | -                  | 延迟时间       |
| priority | GebPriority           | ❌   | GebPriority.normal | 事件优先级     |
| metadata | Map<String, dynamic>? | ❌   | null               | 事件元数据     |

#### 事件监听方法

**listen<T>** - 监听事件

| 参数名     | 类型                  | 必需 | 默认值 | 说明                   |
| ---------- | --------------------- | ---- | ------ | ---------------------- |
| listenerId | String                | ✅   | -      | 监听器唯一标识符       |
| onEvent    | Function(GebEvent<T>) | ✅   | -      | 事件处理回调函数       |
| eventTypes | List<String>?         | ❌   | null   | 指定监听的事件类型列表 |
| onError    | Function(Object)?     | ❌   | null   | 错误回调函数           |

**listenOnce<T>** - 一次性监听事件

| 参数名     | 类型                  | 必需 | 默认值 | 说明                   |
| ---------- | --------------------- | ---- | ------ | ---------------------- |
| listenerId | String                | ✅   | -      | 监听器唯一标识符       |
| onEvent    | Function(GebEvent<T>) | ✅   | -      | 事件处理回调函数       |
| eventTypes | List<String>?         | ❌   | null   | 指定监听的事件类型列表 |

**removeListener** - 移除监听器

| 参数名     | 类型   | 必需 | 默认值 | 说明                 |
| ---------- | ------ | ---- | ------ | -------------------- |
| listenerId | String | ✅   | -      | 要移除的监听器标识符 |

**removeAllListeners** - 移除所有监听器

**cleanupExpiredListeners** - 清理过期的监听器

#### 日志配置方法

**configureLogging** - 配置日志

| 参数名 | 类型         | 必需 | 默认值 | 说明         |
| ------ | ------------ | ---- | ------ | ------------ |
| config | GebLogConfig | ✅   | -      | 日志配置对象 |

**GebLogConfig** 配置参数

| 参数名           | 类型              | 必需 | 默认值           | 说明               |
| ---------------- | ----------------- | ---- | ---------------- | ------------------ |
| level            | GebLogLevel       | ❌   | GebLogLevel.info | 日志级别           |
| enabled          | bool              | ❌   | true             | 是否启用日志       |
| showTimestamp    | bool              | ❌   | true             | 是否显示时间戳     |
| showEventId      | bool              | ❌   | false            | 是否显示事件ID     |
| showPriority     | bool              | ❌   | true             | 是否显示优先级     |
| showEventData    | bool              | ❌   | false            | 是否显示事件数据   |
| showListenerInfo | bool              | ❌   | true             | 是否显示监听器信息 |
| logPrefix        | String            | ❌   | '[GlobalEvent]'  | 自定义日志前缀     |
| eventTypeFilter  | List<String>?     | ❌   | null             | 事件类型过滤器     |
| listenerIdFilter | List<String>?     | ❌   | null             | 监听器ID过滤器     |
| customLogger     | Function(String)? | ❌   | null             | 自定义日志处理函数 |

**GebLogConfig 预设配置**

| 配置                          | 说明                                |
| ----------------------------- | ----------------------------------- |
| GebLogConfig.defaultConfig    | 默认配置：info级别                  |
| GebLogConfig.debugConfig      | 调试配置：debug级别，显示详细信息   |
| GebLogConfig.productionConfig | 生产配置：error级别，不显示敏感信息 |
| GebLogConfig.silentConfig     | 静默配置：禁用所有日志              |

## 📖 文档目录

- [快速开始](doc/getting_started.md) - 安装和基本使用
- [API 参考](doc/api_reference.md) - 完整 API 文档
- [GebBuilder Widget](doc/widgets/geb_builder.md) - 响应式 Widget
- [调试面板](doc/widgets/debug_panel.md) - 开发调试工具
- [GebListener Mixin](doc/mixins/geb_listener.md) - 简化事件订阅
- [GebBlocMixin](doc/mixins/geb_bloc_mixin.md) - BLoC 集成
- [BLoC 集成指南](doc/integration/bloc_integration.md) - 完整集成方案
- [事件优先级](doc/advanced/priority.md) - 优先级系统
- [批量处理模式](doc/advanced/batch_mode.md) - 性能优化

## 📚 详细使用指南

### 事件优先级

事件优先级决定了事件的处理顺序，共有四个级别：

```dart
enum GebPriority {
  low(0),      // 低优先级 - 日志、统计等后台任务
  normal(1),   // 普通优先级 - 默认级别，一般业务事件
  high(2),     // 高优先级 - 用户交互、UI更新等
  critical(3); // 关键优先级 - 系统级重要事件
}

// 使用示例
globalEventBus.sendEvent<String>(
  type: 'emergency_logout',
  data: 'Session expired',
  priority: GebPriority.critical,
);
```

### 批量处理模式

在高频事件场景下，启用批量模式可以显著提升性能：

```dart
// 启用批量模式，每50毫秒处理一批事件
globalEventBus.manager.setBatchMode(true, intervalMs: 50);

// 发送大量事件
for (int i = 0; i < 1000; i++) {
  globalEventBus.sendEvent<int>(
    type: 'batch_event',
    data: i,
  );
}

// 关闭批量模式
globalEventBus.manager.setBatchMode(false);
```

### 多种监听方式

#### 一次性监听

```dart
// 只监听一次，收到事件后自动移除监听器
globalEventBus.listenOnce<String>(
  listenerId: 'splash_page',
  onEvent: (GebEvent<String> event) {
    print('应用初始化完成');
    // 跳转到主页面
  },
);
```

#### 多类型监听

```dart
// 同时监听多种事件类型
globalEventBus.listen<String>(
  listenerId: 'notification_handler',
  eventTypes: ['user_login', 'user_logout', 'message_received'],
  onEvent: (GebEvent<String> event) {
    switch (event.type) {
      case 'user_login':
        handleUserLogin(event);
        break;
      case 'user_logout':
        handleUserLogout(event);
        break;
      case 'message_received':
        handleMessage(event);
        break;
    }
  },
);
```

#### 条件监听

```dart
// 带条件的事件监听
globalEventBus.listen<Map<String, dynamic>>(
  listenerId: 'admin_listener',
  onEvent: (GebEvent<Map<String, dynamic>> event) {
    // 只处理管理员相关的事件
    if (event.data['userRole'] == 'admin') {
      handleAdminEvent(event);
    }
  },
);
```

### 日志配置

#### 预设配置

```dart
// 开发环境 - 详细日志
globalEventBus.configureLogging(GebLogConfig.debugConfig);

// 生产环境 - 只记录错误
globalEventBus.configureLogging(GebLogConfig.productionConfig);

// 关闭所有日志
globalEventBus.configureLogging(GebLogConfig.silentConfig);
```

#### 自定义配置

```dart
// 详细的自定义日志配置
globalEventBus.configureLogging(GebLogConfig(
  level: GebLogLevel.info,           // 日志级别
  enabled: true,                     // 启用日志
  showTimestamp: true,               // 显示时间戳
  showEventId: false,                // 不显示事件ID
  showPriority: true,                // 显示优先级
  showEventData: false,              // 不显示事件数据（生产环境推荐）
  showListenerInfo: true,            // 显示监听器信息
  logPrefix: '[MyApp-Events]',       // 自定义日志前缀
  eventTypeFilter: ['user_action', 'api_call'], // 只记录特定类型的事件
  customLogger: (message) {          // 自定义日志处理器
    // 可以将日志写入文件或发送到服务器
    print('Custom: $message');
  },
));
```

### 性能监控

```dart
// 获取事件统计信息
final stats = globalEventBus.stats;

print('总发送事件数: ${stats.totalEventsSent}');
print('总接收事件数: ${stats.totalEventsReceived}');
print('最后事件时间: ${stats.lastEventTime}');

// 查看各类型事件的发送次数
stats.eventTypeCount.forEach((type, count) {
  print('事件类型 $type: $count 次');
});

// 获取性能信息
final performanceInfo = globalEventBus.performanceInfo;
print('活跃监听器数: ${performanceInfo['listenerCount']}');
print('批量模式: ${performanceInfo['batchEnabled']}');
```

### 事件历史记录

```dart
// 配置历史记录（可选，默认启用，最大100条）
globalEventBus.configureHistory(GebHistoryConfig(
  enabled: true,
  maxHistorySize: 500,
));

// 获取最近的10个事件
final recentEvents = globalEventBus.getRecentEvents(count: 10);

// 获取指定类型最近的5个事件
final loginEvents = globalEventBus.getRecentEventsByType('user_login', count: 5);

// 获取指定类型的最后一个事件
final lastLogin = globalEventBus.getLastEventByType('user_login');

// 获取所有已记录的事件类型
final allTypes = globalEventBus.eventTypes;

// 清空历史记录
globalEventBus.clearHistory();
```

### 🎯 实际应用场景

#### 1. 用户状态管理

```dart
// 用户登录
globalEventBus.sendEvent<UserInfo>(
  type: 'user_login',
  data: UserInfo(id: '123', name: 'John', email: 'john@example.com'),
  priority: GebPriority.high,
);

// 监听用户状态变化, 并在登录后立即更新用户界面
globalEventBus.listen<UserInfo>(
  listenerId: 'user_profile_page',
  onEvent: (GebEvent<UserInfo> event) {
    // 更新用户界面
    updateUserProfile(event.data);
  },
);
```

#### 2. 购物车管理

```dart
// 添加商品到购物车
globalEventBus.sendEvent<CartItem>(
  type: 'cart_add_item',
  data: CartItem(
    productId: 'p001',
    productName: 'iPhone 15',
    price: 999.99,
    quantity: 1,
  ),
);

// 监听购物车变化
globalEventBus.listen<CartItem>(
  listenerId: 'cart_badge',
  eventTypes: ['cart_add_item', 'cart_remove_item', 'cart_update_quantity'],
  onEvent: (GebEvent<CartItem> event) {
    // 更新购物车徽章
    updateCartBadge();
  },
);
```

#### 3. 网络状态监控

```dart
// 网络状态变化
globalEventBus.sendEvent<bool>(
  type: 'network_status_changed',
  data: isConnected,
  priority: GebPriority.critical,
);

// 全局网络状态监听
globalEventBus.listen<bool>(
  listenerId: 'global_network_monitor',
  onEvent: (GebEvent<bool> event) {
    if (event.data) {
      showSnackBar('网络已连接');
    } else {
      showSnackBar('网络已断开');
    }
  },
  eventTypes: ['network_status_changed'],
);
```

#### 4. 主题切换

```dart
// 切换主题
globalEventBus.sendEvent<ThemeMode>(
  type: 'theme_changed',
  data: ThemeMode.dark,
);

// 监听主题变化
globalEventBus.listen<ThemeMode>(
  listenerId: 'main_app',
  onEvent: (GebEvent<ThemeMode> event) {
    // 更新应用主题
    updateAppTheme(event.data);
  },
  eventTypes: ['theme_changed'],
);
```

### 🔧 高级功能

#### GebBuilder 响应式 Widget

```dart
// 使用 GebBuilder 构建响应式 UI
class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GebBuilder<String>(
      eventType: 'notification_received',
      useHistoryForInitialData: true,
      initialData: '暂无通知',
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('错误: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Card(
          child: ListTile(
            title: Text(snapshot.data!),
            subtitle: Text('事件ID: ${snapshot.event?.eventId}'),
          ),
        );
      },
    );
  }
}
```

#### GebListener Mixin

```dart
// 使用 Mixin 简化事件订阅
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with GebListener {
  String _userName = '未登录';

  @override
  void initState() {
    super.initState();

    // 订阅用户登录事件
    gebSubscribe<Map<String, dynamic>>(
      listenerId: 'home_user_login',
      eventType: 'user_login',
      onEvent: (GebEvent<Map<String, dynamic>> event) {
        setState(() {
          _userName = event.data['name'];
        });
      },
    );

    // 订阅一次性事件
    gebSubscribeOnce<void>(
      listenerId: 'home_first_load',
      eventType: 'app_initialized',
      onEvent: (_) {
        print('应用首次加载完成');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('欢迎, $_userName');
  }

  // dispose 时自动取消所有订阅
}
```

#### BLoC 集成

```dart
// 使用 GebBlocBridge 桥接 BLoC 和事件总线
final bridge = GebBlocBridge<CounterEvent, CounterState>(
  bloc: counterBloc,
  stateEventType: 'counter_state_changed',
);

// 启动桥接
bridge.start();

// 将事件总线事件转发到 BLoC
bridge.forwardEventToBloc<int>(
  eventType: 'external_increment',
  mapper: (event) => IncrementEvent(event.data),
);

// 手动发布当前状态
bridge.publishCurrentState();

// 停止桥接（通常在 dispose 中调用）
bridge.dispose();
```

```dart
// 使用 GebBlocMixin 在 BLoC 中直接集成
class CounterBloc extends Bloc<CounterEvent, CounterState> with GebBlocMixin<CounterState> {
  CounterBloc() : super(CounterState(0)) {
    // 初始化事件总线集成
    gebInit(
      eventBus: globalEventBus,
      stateEventType: 'counter_state',
    );
  }

  // ... 其他 BLoC 逻辑 ...

  @override
  Future<void> close() {
    gebDispose(); // 清理资源
    return super.close();
  }
}
```

#### BLoC 事件映射

```dart
// 使用 GebBlocMapper 映射事件
bridge.forwardEventToBloc<String>(
  eventType: 'user_input',
  mapper: GebBlocMapper.direct, // 直接映射
);

// 使用自定义映射
bridge.forwardEventToBloc<Map<String, dynamic>>(
  eventType: 'complex_event',
  mapper: (event) => CustomEvent(
    id: event.data['id'],
    name: event.data['name'],
  ),
);
```

### 🧪 测试支持

```dart
// 在测试中使用
void main() {
  group('Global Event Bus Tests', () {
    setUp(() {
      // 清理之前的监听器
      globalEventBus.removeAllListeners();
    });

    test('should send and receive events', () async {
      String? receivedData;

      // 设置监听器
      final subscription = globalEventBus.listen<String>(
        listenerId: 'test_listener',
        onEvent: (GebEvent<String> event) {
          receivedData = event.data;
        },
      );

      // 发送事件
      globalEventBus.sendEvent<String>(
        type: 'test_event',
        data: 'test_data',
      );

      // 等待事件处理
      await Future.delayed(const Duration(milliseconds: 10));

      // 验证结果
      expect(receivedData, equals('test_data'));

      // 清理
      subscription.cancel();
    });
  });
}
```

### 📊 性能建议

1. **合理使用事件优先级**
   - 系统关键事件使用 `critical` 优先级
   - 用户交互事件使用 `high` 优先级
   - 一般业务事件使用 `normal` 优先级
   - 日志统计事件使用 `low` 优先级

2. **高频事件优化**
   - 对于高频事件（如滚动、动画），启用批量处理模式
   - 合理设置批量处理间隔时间（建议 50-200ms）
   - 避免在事件处理中执行耗时操作

3. **内存管理**
   - 使用 `GebListener` Mixin 或 `GebBuilder` Widget，自动管理订阅生命周期
   - 在 Widget `dispose()` 时取消订阅
   - 避免创建过多的监听器

4. **日志配置**
   - 生产环境使用 `GebLogConfig.productionConfig`
   - 使用事件类型过滤减少日志量
   - 考虑使用自定义日志处理器

5. **历史记录配置**
   - 根据业务需求合理设置最大历史记录数
   - 不需要历史记录时使用 `GebHistoryConfig.disabled`

### 🤝 贡献指南

我们欢迎所有形式的贡献！请查看 CONTRIBUTING.md 了解详细信息。

#### 开发环境设置

```bash
# 克隆仓库
git clone https://gitee.com/pedro-labs/global_event_bus.git
# 进入项目目录
cd global_event_bus
# 安装依赖
flutter pub get
# 运行示例
cd example && flutter run
# 运行测试
flutter test
```

### 📄 许可证

本项目采用 MIT 许可证。

### 🔗 相关链接

- [Pub.dev 发布页](https://pub.dev/packages/global_event_bus)
- [GitHub 仓库](https://github.com/pedro-labs/global_event_bus)
- [Gitee 仓库](https://gitee.com/pedro-labs/global_event_bus)
- [问题反馈](https://gitee.com/pedro-labs/global_event_bus/issues)

### 📝 类命名对照表

为保持向后兼容性，旧类名通过 typedef 保留，但建议新项目使用新的 `Geb` 前缀类名。

| 旧类名                     | 新类名                | 状态         |
| ------------------------- | -------------------- | ----------- |
| GlobalEvent\<T\>          | GebEvent\<T\>        | @Deprecated |
| BaseGlobalEvent           | GebBaseEvent         | @Deprecated |
| EventPriority             | GebPriority          | @Deprecated |
| EventStats                | GebStats             | @Deprecated |
| GlobalEventLogger         | GebLogger            | @Deprecated |
| GlobalEventLogConfig       | GebLogConfig          | @Deprecated |
| EventLogLevel             | GebLogLevel          | @Deprecated |
| EventHistory              | GebHistory           | @Deprecated |
| EventHistoryConfig         | GebHistoryConfig      | @Deprecated |
| EventBusBuilder\<T\>      | GebBuilder\<T\>      | @Deprecated |
| EventBusSnapshot\<T\>     | GebSnapshot\<T\>     | @Deprecated |
| EventBusConnectionState   | GebConnectionState   | @Deprecated |
| EventBusListener          | GebListener          | @Deprecated |
| EventBusNoDataListener    | GebNoDataListener    | @Deprecated |
| EventBusBlocBridge\<E,S\> | GebBlocBridge\<E,S\> | @Deprecated |
| EventBusBlocMixin\<S\>    | GebBlocMixin\<S\>    | @Deprecated |
| BlocEventMapper           | GebBlocMapper        | @Deprecated |
