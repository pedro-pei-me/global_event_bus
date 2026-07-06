import 'dart:async';

import 'global_event_log.dart';
import 'global_event_model.dart';

/// 全局事件总线的核心管理器，负责事件的发送、监听和历史记录。
///
/// 采用单例模式，内部维护事件流、监听器列表、历史记录和批量队列。
/// 所有 [GlobalEventBus] 的方法都委托给此类实现。
class GlobalEventManager {
  static final GlobalEventManager _instance = GlobalEventManager._internal();

  factory GlobalEventManager() => _instance;

  GlobalEventManager._internal();

  /// 全局事件流控制器，广播模式允许多个订阅者
  final StreamController<GebBaseEvent> _globalEventStream = StreamController<GebBaseEvent>.broadcast();

  /// 监听器订阅列表，key为监听器ID
  final Map<String, StreamSubscription<GebBaseEvent>> _subscriptions = {};

  /// 事件统计信息
  final GebStats _stats = GebStats();

  /// 事件历史记录
  final GebHistory _history = GebHistory();

  /// 批量发送队列
  final List<GebBaseEvent> _batchQueue = [];

  /// 批量发送定时器
  Timer? _batchTimer;

  /// 是否启用批量模式
  bool _batchEnabled = false;

  /// 批量发送间隔（毫秒）
  int _batchInterval = 100;

  /// 配置日志行为
  ///
  /// [config] 日志配置，参见 [GebLogConfig]
  void configureLogging(GebLogConfig config) {
    GebLogger.setConfig(config);
    GebLogger.logDebug('日志配置已更新', context: 'GlobalEventManager');
  }

  /// 发送一个不带数据的事件
  ///
  /// [type] 事件类型，必填
  /// [priority] 事件优先级，默认为 [GebPriority.normal]
  /// [metadata] 事件元数据，可选
  void sendWithoutData({
    required String type,
    GebPriority priority = GebPriority.normal,
    Map<String, dynamic>? metadata,
  }) {
    sendEvent<void>(
      type: type,
      data: null,
      priority: priority,
      metadata: metadata,
    );
  }

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
    try {
      final event = GebEvent<T>(
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
      _history.addEvent(event);

      GebLogger.logEventSent(
        type,
        priority,
        eventId: event.eventId,
        data: data,
      );
    } catch (e) {
      GebLogger.logError(
        '发送事件失败: $type',
        error: e,
        context: 'sendEvent',
      );
    }
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
    try {
      sendEvent<T>(
        type: type,
        data: data,
        priority: priority,
        metadata: metadata,
      );
      return true;
    } catch (e) {
      GebLogger.logError(
        '安全发送事件失败: $type',
        error: e,
        context: 'sendEventSafe',
      );
      return false;
    }
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
    GebLogger.logDebug(
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

  /// 内部方法：向事件流发送事件
  void _sendEventInternal(GebBaseEvent event) {
    if (_globalEventStream.isClosed) {
      GebLogger.logWarning(
        '尝试向已关闭的流发送事件: ${event.type}',
        context: '_sendEventInternal',
      );
      return;
    }
    _globalEventStream.add(event);
  }

  /// 内部方法：将事件添加到批量队列
  void _addToBatch(GebBaseEvent event) {
    _batchQueue.add(event);

    _batchTimer?.cancel();
    _batchTimer = Timer(Duration(milliseconds: _batchInterval), () {
      _flushBatch();
    });
  }

  /// 内部方法：刷新批量队列，按优先级排序后发送所有事件
  void _flushBatch() {
    if (_batchQueue.isEmpty) return;

    GebLogger.logDebug(
      '刷新批量队列: ${_batchQueue.length} 个事件',
      context: '_flushBatch',
    );

    _batchQueue.sort((a, b) => b.priority.value.compareTo(a.priority.value));

    for (final event in _batchQueue) {
      _sendEventInternal(event);
    }

    _batchQueue.clear();
    _batchTimer = null;
  }

  /// 设置批量发送模式
  ///
  /// [enabled] 是否启用批量模式
  /// [intervalMs] 批量发送间隔（毫秒），默认为 100ms
  ///
  /// 在批量模式下，事件会被缓存，每隔指定时间批量发送一次，
  /// 并按优先级排序后发送。适合在短时间内发送大量事件时优化性能。
  void setBatchMode(bool enabled, {int intervalMs = 100}) {
    _batchEnabled = enabled;
    _batchInterval = intervalMs;

    GebLogger.logDebug(
      '批量模式${enabled ? "启用" : "禁用"} (间隔: ${intervalMs}ms)',
      context: 'setBatchMode',
    );

    if (!enabled && _batchQueue.isNotEmpty) {
      _flushBatch();
    }
  }

  /// 添加一个带类型的事件监听器
  ///
  /// [listenerId] 监听器唯一标识，必填
  /// [onEvent] 事件回调函数，收到匹配类型的事件时触发
  /// [onError] 错误回调函数，可选
  /// [eventTypes] 要监听的事件类型列表，可选，不指定则监听所有类型
  ///
  /// 返回值：[StreamSubscription]，用于取消订阅
  StreamSubscription<GebBaseEvent> addTypedListener<T>({
    required String listenerId,
    required void Function(GebEvent<T> event) onEvent,
    void Function(Object error)? onError,
    List<String>? eventTypes,
  }) {
    return _addListener(
      listenerId,
      (event) {
        try {
          if (event is GebEvent<T>) {
            GebLogger.logEventReceived(
              event.type,
              listenerId,
              event.priority,
              eventId: event.eventId,
            );

            onEvent(event);
            _stats.recordReceivedEvent();
          }
        } catch (e) {
          GebLogger.logError(
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

  /// 添加一个一次性事件监听器，只触发一次后自动移除
  ///
  /// [listenerId] 监听器唯一标识，必填
  /// [onEvent] 事件回调函数，收到匹配类型的事件时触发
  /// [eventTypes] 要监听的事件类型列表，可选，不指定则监听所有类型
  ///
  /// 返回值：[StreamSubscription]，用于取消订阅
  StreamSubscription<GebBaseEvent> addOnceListener<T>({
    required String listenerId,
    required void Function(GebEvent<T> event) onEvent,
    List<String>? eventTypes,
  }) {
    late StreamSubscription<GebBaseEvent> subscription;

    subscription = addTypedListener<T>(
      listenerId: '${listenerId}_once',
      onEvent: (event) {
        onEvent(event);
        subscription.cancel();
        _subscriptions.remove('${listenerId}_once');
        GebLogger.logDebug(
          '一次性监听器已自动移除: ${listenerId}_once',
          context: 'addOnceListener',
        );
      },
      eventTypes: eventTypes,
    );

    return subscription;
  }

  /// 内部方法：添加监听器
  StreamSubscription<GebBaseEvent> _addListener(
    String listenerId,
    void Function(GebBaseEvent event) onEvent, {
    List<String>? eventTypes,
    void Function(Object error)? onError,
  }) {
    removeListener(listenerId);

    StreamSubscription<GebBaseEvent> subscription;

    Stream<GebBaseEvent> stream = _globalEventStream.stream;

    if (eventTypes != null && eventTypes.isNotEmpty) {
      stream = stream.where((event) => eventTypes.contains(event.type));
    }

    subscription = stream.listen(
      onEvent,
      onError: (error) {
        GebLogger.logError(
          '监听器错误: $listenerId',
          error: error,
          context: '_addListener',
        );
        onError?.call(error);
      },
    );

    _subscriptions[listenerId] = subscription;

    GebLogger.logListenerOperation(
      '添加',
      listenerId,
      eventTypes: eventTypes,
    );

    return subscription;
  }

  /// 根据监听器ID移除指定的监听器
  ///
  /// [listenerId] 要移除的监听器ID
  void removeListener(String listenerId) {
    final subscription = _subscriptions.remove(listenerId);
    if (subscription != null) {
      subscription.cancel();
      GebLogger.logListenerOperation('移除', listenerId);
    }
  }

  /// 移除所有注册的监听器
  void removeAllListeners() {
    final count = _subscriptions.length;
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    GebLogger.logDebug(
      '移除所有监听器: $count 个',
      context: 'removeAllListeners',
    );
  }

  /// 清理过期的监听器（已暂停的订阅）
  void cleanupExpiredListeners() {
    final expiredIds = <String>[];

    for (final entry in _subscriptions.entries) {
      if (entry.value.isPaused) {
        expiredIds.add(entry.key);
      }
    }

    for (final id in expiredIds) {
      removeListener(id);
    }

    if (expiredIds.isNotEmpty) {
      GebLogger.logDebug(
        '清理了 ${expiredIds.length} 个过期监听器',
        context: 'cleanupExpiredListeners',
      );
    }
  }

  /// 销毁管理器，释放所有资源
  ///
  /// 调用此方法后，管理器将无法继续使用
  void dispose() {
    _batchTimer?.cancel();
    _flushBatch();
    removeAllListeners();
    _history.clear();
    _globalEventStream.close();
    GebLogger.logDebug('管理器已销毁', context: 'dispose');
  }

  /// 获取当前注册的监听器数量
  int get listenerCount => _subscriptions.length;

  /// 获取所有监听器ID列表
  List<String> get listenerIds => _subscriptions.keys.toList();

  /// 获取事件统计信息
  GebStats get stats => _stats;

  /// 获取性能信息，包括监听器数量、事件统计、批量模式状态、历史记录状态等
  Map<String, dynamic> get performanceInfo => {
        'listenerCount': listenerCount,
        'totalEventsSent': _stats.totalEventsSent,
        'totalEventsReceived': _stats.totalEventsReceived,
        'eventTypeCount': Map.from(_stats.eventTypeCount),
        'lastEventTime': _stats.lastEventTime?.toIso8601String(),
        'batchEnabled': _batchEnabled,
        'batchQueueSize': _batchQueue.length,
        'historyCount': _history.count,
        'historyEnabled': _history.config.enabled,
      };

  /// 获取事件历史记录管理器
  GebHistory get history => _history;

  /// 配置事件历史记录行为
  ///
  /// [config] 历史记录配置，参见 [GebHistoryConfig]
  void configureHistory(GebHistoryConfig config) {
    _history.configure(config);
    GebLogger.logDebug(
      '历史记录配置已更新: 启用=${config.enabled}, 最大记录数=${config.maxHistorySize}',
      context: 'configureHistory',
    );
  }
}
