import 'dart:async';
import 'global_event_model.dart';
import 'global_event_manager.dart';
import 'global_event_log.dart';

/// 全局事件总线的单例实例，可直接使用。
///
/// 使用方式：
/// ```dart
/// globalEventBus.sendEvent(type: 'user_login', data: user);
/// globalEventBus.listen(listenerId: 'my_listener', onEvent: (event) => ...);
/// ```
final globalEventBus = GlobalEventBus.instance;

/// 全局事件总线的核心 API 类。
///
/// 提供事件发送、监听、历史记录查询等功能，采用单例模式。
/// 所有方法都委托给内部的 [GlobalEventManager] 实现。
class GlobalEventBus {
  static final GlobalEventBus _instance = GlobalEventBus._internal();
  factory GlobalEventBus() => _instance;

  /// 获取全局事件总线的单例实例
  static GlobalEventBus get instance => _instance;

  GlobalEventBus._internal();

  final GlobalEventManager _manager = GlobalEventManager();

  /// 获取内部管理器，用于高级配置和操作
  GlobalEventManager get manager => _manager;

  /// 发送一个带类型数据的事件
  ///
  /// [type] 事件类型，必填
  /// [data] 事件数据，必填，类型为 [T]
  /// [priority] 事件优先级，默认为 [GebPriority.normal]
  /// [metadata] 事件元数据，可选
  void sendEvent<T>({
    required String type,
    required T data,
    GebPriority priority = GebPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    _manager.sendEvent<T>(
      type: type,
      data: data,
      priority: priority,
      metadata: metadata,
    );
  }

  /// 发送一个不带数据的事件
  ///
  /// [type] 事件类型，必填
  /// [priority] 事件优先级，默认为 [GebPriority.normal]
  /// [metadata] 事件元数据，可选
  void sendEventWithoutData({
    required String type,
    GebPriority priority = GebPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    _manager.sendWithoutData(
      type: type,
      priority: priority,
      metadata: metadata,
    );
  }

  /// 安全发送事件，捕获并记录所有异常
  ///
  /// 返回值：发送成功返回 true，失败返回 false
  bool sendEventSafe<T>({
    required String type,
    required T data,
    GebPriority priority = GebPriority.normal,
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
  /// [type] 事件类型，必填
  /// [delay] 延迟时间，必填
  /// [data] 事件数据，必填，类型为 [T]
  /// [priority] 事件优先级，默认为 [GebPriority.normal]
  /// [metadata] 事件元数据，可选
  void sendEventDelayed<T>({
    required String type,
    required Duration delay,
    required T data,
    GebPriority priority = GebPriority.normal,
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

  /// 注册一个事件监听器，监听指定类型的事件
  ///
  /// [listenerId] 监听器唯一标识，必填
  /// [onEvent] 事件回调函数，收到匹配事件时触发
  /// [eventTypes] 要监听的事件类型列表，可选，不指定则监听所有类型
  /// [onError] 错误回调函数，可选
  ///
  /// 返回值：[StreamSubscription]，用于取消订阅
  StreamSubscription<GebBaseEvent> listen<T>({
    required String listenerId,
    required void Function(GebEvent<T> event) onEvent,
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

  /// 注册一个一次性事件监听器，只触发一次后自动移除
  ///
  /// [listenerId] 监听器唯一标识，必填
  /// [onEvent] 事件回调函数，收到匹配事件时触发
  /// [eventTypes] 要监听的事件类型列表，可选，不指定则监听所有类型
  ///
  /// 返回值：[StreamSubscription]，用于取消订阅
  StreamSubscription<GebBaseEvent> listenOnce<T>({
    required String listenerId,
    required void Function(GebEvent<T> event) onEvent,
    List<String>? eventTypes,
  }) {
    return _manager.addOnceListener<T>(
      listenerId: listenerId,
      onEvent: onEvent,
      eventTypes: eventTypes,
    );
  }

  /// 根据监听器ID移除指定的监听器
  ///
  /// [listenerId] 要移除的监听器ID
  void removeListener(String listenerId) {
    _manager.removeListener(listenerId);
  }

  /// 移除所有注册的监听器
  void removeAllListeners() {
    _manager.removeAllListeners();
  }

  /// 清理过期的监听器（已暂停的订阅）
  void cleanupExpiredListeners() {
    _manager.cleanupExpiredListeners();
  }

  /// 配置日志行为
  ///
  /// [config] 日志配置，参见 [GebLogConfig]
  void configureLogging(GebLogConfig config) {
    _manager.configureLogging(config);
  }

  /// 设置批量发送模式
  ///
  /// [enabled] 是否启用批量模式
  /// [intervalMs] 批量发送间隔（毫秒），默认为 100ms
  ///
  /// 在批量模式下，事件会被缓存，每隔指定时间批量发送一次，
  /// 并按优先级排序后发送。适合在短时间内发送大量事件时优化性能。
  void setBatchMode(bool enabled, {int intervalMs = 100}) {
    _manager.setBatchMode(enabled, intervalMs: intervalMs);
  }

  /// 获取事件统计信息
  GebStats get stats => _manager.stats;

  /// 获取当前注册的监听器数量
  int get listenerCount => _manager.listenerCount;

  /// 获取所有监听器ID列表
  List<String> get listenerIds => _manager.listenerIds;

  /// 获取性能信息，包括监听器数量、事件统计、批量模式状态等
  Map<String, dynamic> get performanceInfo => _manager.performanceInfo;

  /// 检查指定ID的监听器是否存在
  ///
  /// [listenerId] 监听器ID
  bool hasListener(String listenerId) {
    return _manager.listenerIds.contains(listenerId);
  }

  /// 获取事件历史记录管理器
  GebHistory get history => _manager.history;

  /// 配置事件历史记录行为
  ///
  /// [config] 历史记录配置，参见 [GebHistoryConfig]
  void configureHistory(GebHistoryConfig config) {
    _manager.configureHistory(config);
  }

  /// 获取最近的 [count] 个事件
  ///
  /// [count] 获取数量，默认为10
  List<GebBaseEvent> getRecentEvents({int count = 10}) {
    return _manager.history.getRecent(count);
  }

  /// 获取指定类型最近的 [count] 个事件
  ///
  /// [type] 事件类型
  /// [count] 获取数量，默认为1
  List<GebBaseEvent> getRecentEventsByType(String type, {int count = 1}) {
    return _manager.history.getRecentByType(type, count: count);
  }

  /// 获取指定类型的最后一个事件
  ///
  /// [type] 事件类型，不存在时返回 null
  GebBaseEvent? getLastEventByType(String type) {
    return _manager.history.getLastByType(type);
  }

  /// 获取所有已记录的事件类型
  List<String> get eventTypes => _manager.history.eventTypes;

  /// 清空所有事件历史记录
  void clearHistory() {
    _manager.history.clear();
  }

  /// 销毁事件总线，释放所有资源
  ///
  /// 调用此方法后，事件总线将无法继续使用
  void dispose() {
    _manager.dispose();
  }
}
