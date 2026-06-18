import 'dart:async';

import 'global_event_log.dart';
import 'global_event_model.dart';

/// 全局事件管理器
///
/// 事件系统的核心管理类，负责事件的发送、监听、统计和生命周期管理。
/// 采用单例模式，通过广播流（Broadcast Stream）实现一对多的事件分发。
///
/// 主要功能：
/// - 事件的发送和延迟发送
/// - 监听器的注册、管理和移除
/// - 事件统计和性能监控
/// - 批量发送模式支持
/// - 日志记录集成
///
/// 该类通常不直接使用，而是通过 [GlobalEventBus] 类提供的便捷 API 来访问。
class GlobalEventManager {
  /// 单例实例
  static final GlobalEventManager _instance = GlobalEventManager._internal();

  factory GlobalEventManager() => _instance;

  GlobalEventManager._internal();

  /// 全局事件流控制器
  ///
  /// 使用广播模式，支持多个监听器同时接收事件。
  final StreamController<BaseGlobalEvent> _globalEventStream =
      StreamController<BaseGlobalEvent>.broadcast();

  /// 存储所有的订阅，用于统一管理
  ///
  /// Key 为监听器ID，Value 为对应的流订阅对象。
  final Map<String, StreamSubscription<BaseGlobalEvent>> _subscriptions = {};

  /// 事件统计
  ///
  /// 记录事件的发送和接收统计数据。
  final EventStats _stats = EventStats();

  /// 批量发送队列
  ///
  /// 当启用批量模式时，事件会先加入此队列，等待定时器触发后统一发送。
  final List<BaseGlobalEvent> _batchQueue = [];

  /// 批量发送定时器
  Timer? _batchTimer;

  /// 是否启用批量发送
  bool _batchEnabled = false;

  /// 批量发送间隔（毫秒）
  int _batchInterval = 100;

  /// 配置日志
  ///
  /// 更新事件管理器的日志配置，影响后续所有日志输出。
  ///
  /// 参数：
  /// - [config] 新的日志配置实例
  void configureLogging(GlobalEventLogConfig config) {
    GlobalEventLogger.setConfig(config);
    GlobalEventLogger.logDebug('日志配置已更新', context: 'GlobalEventManager');
  }

  /// 发送无数据事件
  ///
  /// 用于发送不需要携带数据的事件，内部调用 [sendEvent] 方法。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  void sendWithoutData({
    required String type,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    sendEvent<void>(
      type: type,
      data: null,
      priority: priority,
      metadata: metadata,
    );
  }

  /// 发送特定类型的事件
  ///
  /// 创建并发送一个泛型事件到事件流中。
  /// 如果启用了批量模式，事件会加入队列等待批量发送。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [data] 事件携带的数据
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  void sendEvent<T>({
    required String type,
    required T data,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final event = GlobalEvent<T>(
        type: type,
        data: data,
        priority: priority,
        metadata: metadata,
      );

      if (_batchEnabled) {
        _addToBatch(event);
      } else {
        _sendEventInternal(event);
      }

      _stats.recordSentEvent(type);

      // 记录发送日志
      GlobalEventLogger.logEventSent(
        type,
        priority,
        eventId: event.eventId,
        data: data,
      );
    } catch (e) {
      GlobalEventLogger.logError(
        '发送事件失败: $type',
        error: e,
        context: 'sendEvent',
      );
    }
  }

  /// 安全发送事件（不会抛出异常）
  ///
  /// 与 [sendEvent] 功能相同，但在发生错误时不会抛出异常，
  /// 而是返回布尔值表示发送结果。
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
  bool sendEventSafe<T>({
    required String type,
    required T data,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    try {
      sendEvent<T>(
        type: type,
        data: data,
        priority: priority,
        metadata: metadata,
      );
      return true;
    } catch (e) {
      GlobalEventLogger.logError(
        '安全发送事件失败: $type',
        error: e,
        context: 'sendEventSafe',
      );
      return false;
    }
  }

  /// 延迟发送事件
  ///
  /// 在指定的延迟时间后发送事件。使用 Timer 实现，不会阻塞当前执行流。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [delay] 延迟时间
  /// - [data] 事件携带的数据
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  void sendEventDelayed<T>({
    required String type,
    required Duration delay,
    required T data,
    EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    GlobalEventLogger.logDebug(
      '延迟发送事件: $type (延迟: ${delay.inMilliseconds}ms)',
      context: 'sendEventDelayed',
    );

    Timer(delay, () {
      sendEvent<T>(
        type: type,
        data: data,
        priority: priority,
        metadata: metadata,
      );
    });
  }

  /// 内部发送事件方法
  ///
  /// 将事件添加到事件流中。如果流已关闭则不发送并记录警告。
  ///
  /// 参数：
  /// - [event] 要发送的事件对象
  void _sendEventInternal(BaseGlobalEvent event) {
    if (_globalEventStream.isClosed) {
      GlobalEventLogger.logWarning(
        '尝试向已关闭的流发送事件: ${event.type}',
        context: '_sendEventInternal',
      );
      return;
    }
    _globalEventStream.add(event);
  }

  /// 添加到批量队列
  ///
  /// 将事件加入批量发送队列，并重置定时器。
  /// 定时器到期后会调用 [_flushBatch] 发送所有队列中的事件。
  ///
  /// 参数：
  /// - [event] 要加入队列的事件对象
  void _addToBatch(BaseGlobalEvent event) {
    _batchQueue.add(event);

    _batchTimer?.cancel();
    _batchTimer = Timer(Duration(milliseconds: _batchInterval), () {
      _flushBatch();
    });
  }

  /// 刷新批量队列
  ///
  /// 将队列中的所有事件按优先级排序后依次发送，然后清空队列。
  void _flushBatch() {
    if (_batchQueue.isEmpty) return;

    GlobalEventLogger.logDebug(
      '刷新批量队列: ${_batchQueue.length} 个事件',
      context: '_flushBatch',
    );

    // 按优先级排序（优先级高的先发送）
    _batchQueue.sort((a, b) => b.priority.value.compareTo(a.priority.value));

    for (final event in _batchQueue) {
      _sendEventInternal(event);
    }

    _batchQueue.clear();
    _batchTimer = null;
  }

  /// 启用/禁用批量发送
  ///
  /// 控制是否启用批量发送模式。禁用时如果队列中有事件会立即刷新。
  ///
  /// 参数：
  /// - [enabled] 是否启用批量模式
  /// - [intervalMs] 批量发送间隔（毫秒），默认 100ms
  void setBatchMode(bool enabled, {int intervalMs = 100}) {
    _batchEnabled = enabled;
    _batchInterval = intervalMs;

    GlobalEventLogger.logDebug(
      '批量模式${enabled ? "启用" : "禁用"} (间隔: ${intervalMs}ms)',
      context: 'setBatchMode',
    );

    if (!enabled && _batchQueue.isNotEmpty) {
      _flushBatch();
    }
  }

  /// 类型安全的监听器添加方法
  ///
  /// 注册一个类型安全的事件监听器。监听器只会接收指定泛型类型的事件。
  ///
  /// 参数：
  /// - [listenerId] 监听器的唯一标识符
  /// - [onEvent] 事件处理回调函数
  /// - [onError] 可选的错误处理回调
  /// - [eventTypes] 可选的事件类型过滤列表
  ///
  /// 返回值：
  /// - [StreamSubscription] 对象，可用于取消订阅
  StreamSubscription<BaseGlobalEvent> addTypedListener<T>({
    required String listenerId,
    required void Function(GlobalEvent<T> event) onEvent,
    void Function(Object error)? onError,
    List<String>? eventTypes,
  }) {
    return _addListener(
      listenerId,
      (event) {
        try {
          if (event is GlobalEvent<T>) {
            // 记录接收日志
            GlobalEventLogger.logEventReceived(
              event.type,
              listenerId,
              event.priority,
              eventId: event.eventId,
            );

            onEvent(event);
            _stats.recordReceivedEvent();
          }
        } catch (e) {
          GlobalEventLogger.logError(
            '事件处理错误',
            error: e,
            context: 'addTypedListener:$listenerId',
          );
          onError?.call(e);
        }
      },
      eventTypes: eventTypes,
      onError: onError,
    );
  }

  /// 一次性监听器
  ///
  /// 注册一个只触发一次的事件监听器。在接收到第一个匹配的事件后会自动取消订阅并移除。
  ///
  /// 参数：
  /// - [listenerId] 监听器的唯一标识符（内部会添加 '_once' 后缀）
  /// - [onEvent] 事件处理回调函数
  /// - [eventTypes] 可选的事件类型过滤列表
  ///
  /// 返回值：
  /// - [StreamSubscription] 对象，可用于提前取消订阅
  StreamSubscription<BaseGlobalEvent> addOnceListener<T>({
    required String listenerId,
    required void Function(GlobalEvent<T> event) onEvent,
    List<String>? eventTypes,
  }) {
    late StreamSubscription<BaseGlobalEvent> subscription;

    subscription = addTypedListener<T>(
      listenerId: '${listenerId}_once',
      onEvent: (event) {
        onEvent(event);
        subscription.cancel();
        _subscriptions.remove('${listenerId}_once');
        GlobalEventLogger.logDebug(
          '一次性监听器已自动移除: ${listenerId}_once',
          context: 'addOnceListener',
        );
      },
      eventTypes: eventTypes,
    );

    return subscription;
  }

  /// 添加监听器（内部方法）
  ///
  /// 注册一个事件监听器到全局事件流。如果已存在同名监听器会先移除旧的。
  ///
  /// 参数：
  /// - [listenerId] 监听器的唯一标识符
  /// - [onEvent] 事件处理回调函数
  /// - [eventTypes] 可选的事件类型过滤列表
  /// - [onError] 可选的错误处理回调
  ///
  /// 返回值：
  /// - [StreamSubscription] 对象，可用于取消订阅
  StreamSubscription<BaseGlobalEvent> _addListener(
    String listenerId,
    void Function(BaseGlobalEvent event) onEvent, {
    List<String>? eventTypes,
    void Function(Object error)? onError,
  }) {
    // 如果已存在同名监听器，先取消
    removeListener(listenerId);

    StreamSubscription<BaseGlobalEvent> subscription;

    Stream<BaseGlobalEvent> stream = _globalEventStream.stream;

    if (eventTypes != null && eventTypes.isNotEmpty) {
      // 只监听指定类型的事件
      stream = stream.where((event) => eventTypes.contains(event.type));
    }

    subscription = stream.listen(
      onEvent,
      onError: (error) {
        GlobalEventLogger.logError(
          '监听器错误: $listenerId',
          error: error,
          context: '_addListener',
        );
        onError?.call(error);
      },
    );

    _subscriptions[listenerId] = subscription;

    // 记录监听器操作日志
    GlobalEventLogger.logListenerOperation(
      '添加',
      listenerId,
      eventTypes: eventTypes,
    );

    return subscription;
  }

  /// 移除指定监听器
  ///
  /// 根据监听器ID取消订阅并从订阅列表中移除。
  ///
  /// 参数：
  /// - [listenerId] 要移除的监听器ID
  void removeListener(String listenerId) {
    final subscription = _subscriptions.remove(listenerId);
    if (subscription != null) {
      subscription.cancel();
      GlobalEventLogger.logListenerOperation('移除', listenerId);
    }
  }

  /// 移除所有监听器
  ///
  /// 取消所有已注册的监听器订阅并清空订阅列表。
  void removeAllListeners() {
    final count = _subscriptions.length;
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    GlobalEventLogger.logDebug(
      '移除所有监听器: $count 个',
      context: 'removeAllListeners',
    );
  }

  /// 自动清理过期监听器
  ///
  /// 检查并移除已暂停的监听器，释放内存资源。
  /// 建议在应用生命周期中定期调用此方法。
  void cleanupExpiredListeners() {
    final expiredIds = <String>[];

    for (final entry in _subscriptions.entries) {
      // 检查监听器是否仍然有效
      if (entry.value.isPaused) {
        expiredIds.add(entry.key);
      }
    }

    for (final id in expiredIds) {
      removeListener(id);
    }

    if (expiredIds.isNotEmpty) {
      GlobalEventLogger.logDebug(
        '清理了 ${expiredIds.length} 个过期监听器',
        context: 'cleanupExpiredListeners',
      );
    }
  }

  /// 销毁管理器
  ///
  /// 释放所有资源，包括取消定时器、刷新队列、移除所有监听器和关闭事件流。
  /// 通常在应用退出时调用。
  void dispose() {
    _batchTimer?.cancel();
    _flushBatch();
    removeAllListeners();
    _globalEventStream.close();
    GlobalEventLogger.logDebug('管理器已销毁', context: 'dispose');
  }

  /// 获取当前监听器数量
  int get listenerCount => _subscriptions.length;

  /// 获取所有监听器ID
  List<String> get listenerIds => _subscriptions.keys.toList();

  /// 获取事件统计信息
  EventStats get stats => _stats;

  /// 获取性能信息
  ///
  /// 返回包含当前系统运行状态的详细信息映射。
  Map<String, dynamic> get performanceInfo => {
        'listenerCount': listenerCount,
        'totalEventsSent': _stats.totalEventsSent,
        'totalEventsReceived': _stats.totalEventsReceived,
        'eventTypeCount': Map.from(_stats.eventTypeCount),
        'lastEventTime': _stats.lastEventTime?.toIso8601String(),
        'batchEnabled': _batchEnabled,
        'batchQueueSize': _batchQueue.length,
      };
}
