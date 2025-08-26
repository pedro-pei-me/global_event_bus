# 🚀 Global Event Bus - 全局事件总线

<div align="center">
  <img src="assets/icons/animated_logo.svg" alt="Global Event Bus Logo" width="400" height="200">
</div>

[![pub package](https://img.shields.io/pub/v/global_event_bus.svg)](https://pub.dev/packages/global_event_bus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个高性能、类型安全的 Flutter 全局事件分发系统，用于在应用程序的不同模块之间进行解耦通信。采用观察者模式和流式处理架构，支持事件优先级、批量处理、延迟发送、统计监控等高级功能。

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
import 'package:global_event_bus/global_event_bus.dart';
```

### 2. 配置日志（可选）

```dart
void main() {
  // 配置全局事件总线日志
  globalEventBus.configureLogging(
    const GlobalEventLogConfig(
      level: EventLogLevel.debug,
      showEventData: true,
      showEventId: true,
      showListenerInfo: true,
    ),
  );
  
  runApp(MyApp());
}
```

### 3. 发送事件

```dart
// 发送简单事件
globalEventBus.sendEvent<String>(
  type: 'user_message',
  data: 'Hello, World!',
);

// 发送带优先级的事件
globalEventBus.sendEvent<Map<String, dynamic>>(
  type: 'user_login',
  data: {
    'userId': '12345',
    'username': 'john_doe',
    'loginTime': DateTime.now().toIso8601String(),
  },
  priority: EventPriority.high,
);

// 延迟发送事件
globalEventBus.sendEventDelayed<String>(
  type: 'delayed_notification',
  data: '这是一个延迟消息',
  delay: Duration(milliseconds: 3000), // 3秒后发送
);
```

### 4. 监听事件

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    
    // 监听特定类型的事件
    _subscription = globalEventBus.listen<String>(
      listenerId: 'my_widget_listener',
      onEvent: (event) {
        print('收到事件: ${event.type}, 数据: ${event.data}');
        // 处理事件数据
        setState(() {
          // 更新UI
        });
      },
    );
  }
  
  @override
  void dispose() {
    _subscription.cancel(); // 取消订阅
    super.dispose();
  }
}
```

### API 参数说明

#### 事件发送方法

**sendEvent<T>** - 发送带数据的事件

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| type | String | ✅ | - | 事件类型标识符 |
| data | T | ✅ | - | 事件携带的数据 |
| priority | EventPriority | ❌ | EventPriority.normal | 事件优先级 |
| metadata | Map<String, dynamic>? | ❌ | null | 事件元数据 |

**sendEventWithoutData** - 发送无数据事件

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| type | String | ✅ | - | 事件类型标识符 |
| priority | EventPriority | ❌ | EventPriority.normal | 事件优先级 |
| metadata | Map<String, dynamic>? | ❌ | null | 事件元数据 |

**sendEventDelayed<T>** - 延迟发送事件

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| type | String | ✅ | - | 事件类型标识符 |
| data | T | ✅ | - | 事件携带的数据 |
| delay | Duration | ✅ | - | 延迟时间 |
| priority | EventPriority | ❌ | EventPriority.normal | 事件优先级 |
| metadata | Map<String, dynamic>? | ❌ | null | 事件元数据 |

#### 事件监听方法

**listen<T>** - 监听事件

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| listenerId | String | ✅ | - | 监听器唯一标识符 |
| onEvent | Function(GlobalEvent<T>) | ✅ | - | 事件处理回调函数 |
| eventTypes | List<String>? | ❌ | null | 指定监听的事件类型列表 |

**listenOnce<T>** - 一次性监听事件

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| listenerId | String | ✅ | - | 监听器唯一标识符 |
| onEvent | Function(GlobalEvent<T>) | ✅ | - | 事件处理回调函数 |
| eventTypes | List<String>? | ❌ | null | 指定监听的事件类型列表 |

**removeListener** - 移除监听器

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| listenerId | String | ✅ | - | 要移除的监听器标识符 |

#### 日志配置方法

**configureLogging** - 配置日志

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| config | GlobalEventLogConfig | ✅ | - | 日志配置对象 |

**GlobalEventLogConfig** 配置参数

| 参数名 | 类型 | 必需 | 默认值 | 说明 |
|--------|------|------|--------|------|
| level | EventLogLevel | ❌ | EventLogLevel.info | 日志级别 |
| enabled | bool | ❌ | true | 是否启用日志 |
| showTimestamp | bool | ❌ | true | 是否显示时间戳 |
| showEventId | bool | ❌ | false | 是否显示事件ID |
| showPriority | bool | ❌ | true | 是否显示优先级 |
| showEventData | bool | ❌ | true | 是否显示事件数据 |
| showListenerInfo | bool | ❌ | false | 是否显示监听器信息 |
| logPrefix | String? | ❌ | null | 自定义日志前缀 |
| eventTypeFilter | List<String>? | ❌ | null | 事件类型过滤器 |
| listenerFilter | List<String>? | ❌ | null | 监听器过滤器 |
| customLogger | Function(String)? | ❌ | null | 自定义日志处理函数 |

## 📚 详细使用指南

事件优先级
事件优先级决定了事件的处理顺序，共有四个级别：

```dart
enum EventPriority {
  low(0),      // 低优先级 - 日志、统计等后台任务
  normal(1),   // 普通优先级 - 默认级别，一般业务事件
  high(2),     // 高优先级 - 用户交互、UI更新等
  critical(3); // 关键优先级 - 系统级重要事件
}

// 使用示例
globalEventBus.sendEvent(
  type: 'emergency_logout',
  data: 'Session expired',
  priority: EventPriority.critical,
);
```

批量处理模式
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

多种监听方式
一次性监听

```dart
// 只监听一次，收到事件后自动移除监听器
globalEventBus.manager.addOnceListener<String>(
  listenerId: 'splash_page',
  onEvent: (event) {
    print('应用初始化完成');
    // 跳转到主页面
  },
);
```

多类型监听

```dart
// 同时监听多种事件类型
globalEventBus.listen(
  listenerId: 'notification_handler',
  eventTypes: ['user_login', 'user_logout', 'message_received'],
  onEvent: (event) {
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

条件监听

```dart
// 带条件的事件监听
globalEventBus.listen<Map<String, dynamic>>(
  listenerId: 'admin_listener',
  onEvent: (event) {
    // 只处理管理员相关的事件
    if (event.data['userRole'] == 'admin') {
      handleAdminEvent(event);
    }
  },
);
```

日志配置
预设配置

```dart

// 开发环境 - 详细日志
enableDebugLogging();

// 生产环境 - 只记录错误
enableProductionLogging();

// 关闭所有日志
disableLogging();
```

自定义配置

```dart
// 详细的自定义日志配置
configureGlobalEventLogging(GlobalEventLogConfig(
  level: EventLogLevel.info,           // 日志级别
  enabled: true,                       // 启用日志
  showTimestamp: true,                 // 显示时间戳
  showEventId: false,                  // 不显示事件ID
  showPriority: true,                  // 显示优先级
  showEventData: false,                // 不显示事件数据（生产环境推荐）
  showListenerInfo: true,              // 显示监听器信息
  logPrefix: '[MyApp-Events]',         // 自定义日志前缀
  eventTypeFilter: ['user_action', 'api_call'], // 只记录特定类型的事件
  customLogger: (message) {            // 自定义日志处理器
    // 可以将日志写入文件或发送到服务器
    print('Custom: $message');
  },
));
```

性能监控

```dart
// 获取事件统计信息
final stats = globalEventBus.manager.stats;

print('总发送事件数: ${stats.totalEventsSent}');
print('总接收事件数: ${stats.totalEventsReceived}');
print('最后事件时间: ${stats.lastEventTime}');

// 查看各类型事件的发送次数
stats.eventTypeCount.forEach((type, count) {
  print('事件类型 $type: $count 次');
});
```

批量发送事件

```dart
// 批量发送多个事件
final events = [
  GlobalEvent<String>(type: 'event1', data: 'data1'),
  GlobalEvent<int>(type: 'event2', data: 42),
  GlobalEvent<bool>(type: 'event3', data: true),
];

globalEventBus.sendEventBatch(events);
```

🎯 实际应用场景

1. 用户状态管理

```dart
// 用户登录
globalEventBus.sendEvent<UserInfo>(
  type: 'user_login',
  data: UserInfo(id: '123', name: 'John', email: 'john@example.com'),
  priority: EventPriority.high,
);

// 监听用户状态变化, 并在登录后立即更新用户界面
globalEventBus.listen<UserInfo>(
  listenerId: 'user_profile_page',
  onEvent: (event) {
    // 更新用户界面
    updateUserProfile(event.data);
  },
  // 如果其他地方没有 [UserInfo] 的监听, 则不需要传`eventTypes`参数
  // eventTypes: ['user_login'],
);
```

2. 购物车管理

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
  onEvent: (event) {
    // 更新购物车徽章
    updateCartBadge();
  },
);
```

3. 网络状态监控

```dart
// 网络状态变化
globalEventBus.sendEvent<bool>(
  type: 'network_status_changed',
  data: isConnected,
  priority: EventPriority.critical,
);

// 全局网络状态监听
globalEventBus.listen<bool>(
  listenerId: 'global_network_monitor',
  onEvent: (event) {
    if (event.data) {
      showSnackBar('网络已连接');
    } else {
      showSnackBar('网络已断开');
    }
  },
  eventTypes: ['network_status_changed'],
);
```

4. 主题切换

```dart
// 切换主题
globalEventBus.sendEvent<ThemeMode>(
  type: 'theme_changed',
  data: ThemeMode.dark,
);

// 监听主题变化
globalEventBus.listen<ThemeMode>(
  listenerId: 'main_app',
  onEvent: (event) {
    // 更新应用主题
    updateAppTheme(event.data);
  },
  eventTypes: ['theme_changed'],
);
```

🔧 高级功能
事件拦截器

```dart
// 添加事件拦截器（即将推出）
globalEventBus.manager.addInterceptor((event) {
  // 在事件发送前进行处理
  if (event.type.startsWith('sensitive_')) {
    // 敏感事件需要权限检查
    if (!hasPermission()) {
      return null; // 阻止事件发送
    }
  }
  return event; // 允许事件发送
});
```

事件持久化

```dart
// 启用事件持久化（即将推出）
globalEventBus.manager.enablePersistence(
  storage: SharedPreferencesStorage(),
  eventTypes: ['user_preferences', 'app_settings'],
);
```

🧪 测试支持

```dart
// 在测试中使用
void main() {
  group('Global Event Bus Tests', () {
    setUp(() {
      // 重置事件总线状态
      globalEventBus.manager.reset();
    });

    test('should send and receive events', () async {
      String? receivedData;

      // 设置监听器
      final subscription = globalEventBus.listen<String>(
        listenerId: 'test_listener',
        onEvent: (event) {
          receivedData = event.data;
        },
      );

      // 发送事件
      globalEventBus.sendEvent<String>(
        type: 'test_event',
        data: 'test_data',
      );

      // 等待事件处理
      await Future.delayed(Duration(milliseconds: 10));

      // 验证结果
      expect(receivedData, equals('test_data'));

      // 清理
      subscription.cancel();
    });
  });
}
```

📊 性能建议

1. 合理使用事件优先级
   系统关键事件使用 critical 优先级
   用户交互事件使用 high 优先级
   一般业务事件使用 normal 优先级
   日志统计事件使用 low 优先级
2. 高频事件优化
   对于高频事件（如滚动、动画），启用批量处理模式
   合理设置批量处理间隔时间
   避免在事件处理中执行耗时操作
3. 内存管理
   及时取消不需要的事件监听器
   在 Widget dispose 时取消订阅
   避免创建过多的监听器
4. 日志配置
   生产环境关闭详细日志
   使用事件类型过滤减少日志量
   考虑使用自定义日志处理器
   🤝 贡献指南
   我们欢迎所有形式的贡献！请查看 CONTRIBUTING.md 了解详细信息。

开发环境设置

```bash
# 克隆仓库
git clone https://gitee.com/peiduo_734386/global_event_bus.git
# 进入项目目录
cd global_event_bus
# 安装依赖
flutter pub get
# 运行示例
cd example && flutter run
# 运行测试
flutter test
```

📄 许可证
本项目采用 MIT 许可证。

🔗 相关链接
