import 'dart:async';
import 'global_event_model.dart';
import 'global_event_manager.dart';
import 'global_event_log.dart';

/// # 全局事件总线系统 (Global Event Bus System)
///
/// 这是一个高性能、类型安全的全局事件分发系统，用于在应用程序的不同模块之间进行解耦通信。
/// 采用观察者模式和流式处理架构，支持事件优先级、批量处理、日志监控等高级功能。
///
/// 便捷的全局事件管理器实例
final globalEventBus = GlobalEventBus.instance;

/// 全局事件总线 API
///
/// 提供全局事件的发送、监听和管理功能。
/// 这是一个单例类，通过 [globalEventBus] 全局实例访问。
///
/// 主要功能：
/// - 发送各种类型的事件（带数据、无数据、延迟发送等）
/// - 监听和管理事件订阅
/// - 配置日志和批量处理
/// - 获取事件统计信息
///
/// 示例用法：
/// ```dart
/// // 发送事件
/// globalEventBus.sendEvent<String>(
///   type: 'user_login',
///   data: 'user123',
/// );
///
/// // 监听事件
/// final subscription = globalEventBus.listen<String>(
///   listenerId: 'my_listener',
///   onEvent: (event) => print('收到: ${event.data}'),
/// );
/// ```
class GlobalEventBus {
  static final GlobalEventBus _instance = GlobalEventBus._internal();
  factory GlobalEventBus() => _instance;
  static GlobalEventBus get instance => _instance;

  GlobalEventBus._internal();

  final GlobalEventManager _manager = GlobalEventManager();

  /// 获取管理器实例
  GlobalEventManager get manager => _manager;

  /// 发送带数据的事件
  ///
  /// 这是最常用的事件发送方法，可以携带任意类型的数据。
  ///
  /// 参数：
  /// - [type] 事件类型标识符，用于区分不同的事件
  /// - [data] 事件携带的数据，类型为泛型 T
  /// - [priority] 事件优先级，影响事件处理顺序，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据，用于传递额外信息
  ///
  /// 示例：
  /// ```dart
  /// // 发送字符串数据
  /// globalEventBus.sendEvent<String>(
  ///   type: 'message',
  ///   data: 'Hello World',
  ///   priority: EventPriority.high,
  /// );
  ///
  /// // 发送复杂对象
  /// globalEventBus.sendEvent<UserInfo>(
  ///   type: 'user_login',
  ///   data: UserInfo(id: '123', name: 'John'),
  ///   metadata: {'source': 'login_page'},
  /// );
  /// ```
  void sendEvent<T>({
    required String type,
    required T data,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    _manager.sendEvent<T>(
      type: type,
      data: data,
      priority: priority,
      metadata: metadata,
    );
  }

  /// 发送无数据事件
  ///
  /// 用于发送不需要携带数据的事件，如状态变更通知、触发器事件等。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  ///
  /// 示例：
  /// ```dart
  /// // 应用启动事件
  /// globalEventBus.sendEventWithoutData(
  ///   type: 'app_started',
  ///   priority: EventPriority.high,
  /// );
  ///
  /// // 用户登出事件
  /// globalEventBus.sendEventWithoutData(
  ///   type: 'user_logout',
  ///   metadata: {'reason': 'manual'},
  /// );
  /// ```
  void sendEventWithoutData({
    required String type,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    _manager.sendWithoutData(
      type: type,
      priority: priority,
      metadata: metadata,
    );
  }

  /// 安全发送事件（不会抛出异常）
  ///
  /// 与 [sendEvent] 功能相同，但在发生错误时不会抛出异常，
  /// 而是返回布尔值表示发送结果。适用于不希望因事件发送失败而中断程序的场景。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [data] 事件携带的数据
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  ///
  /// 返回值：
  /// - `true` 表示发送成功
  /// - `false` 表示发送失败
  ///
  /// 示例：
  /// ```dart
  /// final success = globalEventBus.sendEventSafe<String>(
  ///   type: 'risky_operation',
  ///   data: 'some data',
  /// );
  ///
  /// if (!success) {
  ///   print('事件发送失败，但程序继续执行');
  /// }
  /// ```
  bool sendEventSafe<T>({
    required String type,
    required T data,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    return _manager.sendEventSafe<T>(
      type: type,
      data: data,
      priority: priority,
      metadata: metadata,
    );
  }

  /// 延迟发送事件
  ///
  /// 在指定的延迟时间后发送事件。适用于需要延迟执行的操作，
  /// 如定时提醒、延迟加载等场景。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [data] 事件携带的数据
  /// - [delay] 延迟时间，使用 [Duration] 对象指定
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  ///
  /// 示例：
  /// ```dart
  /// // 3秒后发送提醒
  /// globalEventBus.sendEventDelayed<String>(
  ///   type: 'reminder',
  ///   data: '该休息了！',
  ///   delay: Duration(seconds: 3),
  /// );
  ///
  /// // 延迟加载数据
  /// globalEventBus.sendEventDelayed<String>(
  ///   type: 'load_data',
  ///   data: 'user_profile',
  ///   delay: Duration(milliseconds: 500),
  ///   priority: EventPriority.high,
  /// );
  /// ```
  void sendEventDelayed<T>({
    required String type,
    required Duration delay,
    required T data,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    _manager.sendEventDelayed<T>(
      type: type,
      delay: delay,
      data: data,
      priority: priority,
      metadata: metadata,
    );
  }

  /// 监听事件
  ///
  /// 注册一个事件监听器来接收指定类型的事件。这是最常用的事件监听方法。
  ///
  /// 参数：
  /// - [listenerId] 监听器的唯一标识符，用于管理和移除监听器
  /// - [onEvent] 事件处理回调函数，接收 [GlobalEvent<T>] 类型的事件对象
  /// - [eventTypes] 可选的事件类型过滤列表，如果不指定则监听所有类型的事件
  /// - [onError] 可选的错误处理回调函数
  ///
  /// 返回值：
  /// - [StreamSubscription] 对象，可用于取消订阅
  ///
  /// 注意事项：
  /// - 每个 [listenerId] 在同一时间只能有一个活跃的监听器
  /// - 建议在不需要时及时取消订阅以避免内存泄漏
  /// - 在 Widget 的 dispose 方法中取消订阅
  ///
  /// 示例：
  /// ```dart
  /// // 监听特定类型的事件
  /// final subscription = globalEventBus.listen<String>(
  ///   listenerId: 'my_page_listener',
  ///   onEvent: (event) {
  ///     print('收到事件: ${event.type}, 数据: ${event.data}');
  ///   },
  ///   eventTypes: ['user_login', 'user_logout'],
  /// );
  ///
  /// // 在适当时机取消订阅
  /// subscription.cancel();
  /// ```
  StreamSubscription<BaseGlobalEvent> listen<T>({
    required String listenerId,
    required void Function(GlobalEvent<T> event) onEvent,
    List<String>? eventTypes,
    void Function(Object error)? onError,
  }) {
    return _manager.addTypedListener<T>(
      listenerId: listenerId,
      onEvent: onEvent,
      eventTypes: eventTypes,
      onError: onError,
    );
  }

  /// 一次性监听事件
  ///
  /// 注册一个只触发一次的事件监听器。监听器在接收到第一个匹配的事件后会自动移除。
  /// 适用于只需要处理一次性事件的场景，如初始化完成、首次登录等。
  ///
  /// 参数：
  /// - [listenerId] 监听器的唯一标识符
  /// - [onEvent] 事件处理回调函数，接收 [GlobalEvent<T>] 类型的事件对象
  /// - [eventTypes] 可选的事件类型过滤列表
  ///
  /// 返回值：
  /// - [StreamSubscription] 对象，可用于提前取消订阅
  ///
  /// 示例：
  /// ```dart
  /// // 等待应用初始化完成
  /// globalEventBus.listenOnce<bool>(
  ///   listenerId: 'init_waiter',
  ///   onEvent: (event) {
  ///     print('应用初始化完成: ${event.data}');
  ///     // 这个监听器会自动移除
  ///   },
  ///   eventTypes: ['app_initialized'],
  /// );
  /// ```
  StreamSubscription<BaseGlobalEvent> listenOnce<T>({
    required String listenerId,
    required void Function(GlobalEvent<T> event) onEvent,
    List<String>? eventTypes,
  }) {
    return _manager.addOnceListener<T>(
      listenerId: listenerId,
      onEvent: onEvent,
      eventTypes: eventTypes,
    );
  }

  /// 移除监听器
  ///
  /// 根据监听器ID移除指定的事件监听器。
  ///
  /// 参数：
  /// - [listenerId] 要移除的监听器ID
  ///
  /// 示例：
  /// ```dart
  /// globalEventBus.removeListener('my_listener');
  /// ```
  void removeListener(String listenerId) {
    _manager.removeListener(listenerId);
  }

  /// 移除所有监听器
  ///
  /// 清除所有已注册的事件监听器。通常在应用关闭或重置时使用。
  ///
  /// 注意：此操作不可逆，请谨慎使用。
  ///
  /// 示例：
  /// ```dart
  /// globalEventBus.removeAllListeners();
  /// ```
  void removeAllListeners() {
    _manager.removeAllListeners();
  }

  /// 清理过期监听器
  ///
  /// 清理已过期或无效的监听器，释放内存资源。
  /// 建议定期调用此方法以保持系统性能。
  ///
  /// 示例：
  /// ```dart
  /// // 定期清理
  /// Timer.periodic(Duration(minutes: 5), (_) {
  ///   globalEventBus.cleanupExpiredListeners();
  /// });
  /// ```
  void cleanupExpiredListeners() {
    _manager.cleanupExpiredListeners();
  }

  /// 配置日志
  void configureLogging(GlobalEventLogConfig config) {
    _manager.configureLogging(config);
  }

  /// 启用/禁用批量发送模式
  void setBatchMode(bool enabled, {int intervalMs = 100}) {
    _manager.setBatchMode(enabled, intervalMs: intervalMs);
  }

  /// 获取统计信息
  EventStats get stats => _manager.stats;

  /// 获取当前监听器数量
  int get listenerCount => _manager.listenerCount;

  /// 获取所有监听器ID
  List<String> get listenerIds => _manager.listenerIds;

  /// 获取性能信息
  Map<String, dynamic> get performanceInfo => _manager.performanceInfo;

  /// 检查是否有指定的监听器
  bool hasListener(String listenerId) {
    return _manager.listenerIds.contains(listenerId);
  }

  /// 销毁
  void dispose() {
    _manager.dispose();
  }
}
