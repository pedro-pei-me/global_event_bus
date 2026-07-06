import 'package:flutter/foundation.dart';

import 'global_event_model.dart';

/// 日志级别枚举，控制日志输出的详细程度。
///
/// 级别从低到高：[none] < [error] < [warning] < [info] < [debug]
/// 只有级别大于等于当前配置级别的日志才会输出。
enum GebLogLevel {
  /// 不输出任何日志
  none,

  /// 仅输出错误日志
  error,

  /// 输出错误和警告日志
  warning,

  /// 输出错误、警告和信息日志（默认）
  info,

  /// 输出所有日志，包括调试信息
  debug,
}

@Deprecated('Use GebLogLevel instead. Will be removed in a future version')
typedef EventLogLevel = GebLogLevel;

/// 日志配置类，用于配置全局事件总线的日志行为。
class GebLogConfig {
  /// 日志级别，低于此级别的日志不会输出
  final GebLogLevel level;

  /// 是否启用日志功能
  final bool enabled;

  /// 是否显示时间戳
  final bool showTimestamp;

  /// 是否显示事件ID
  final bool showEventId;

  /// 是否显示事件优先级
  final bool showPriority;

  /// 是否显示事件数据
  final bool showEventData;

  /// 是否显示监听器信息
  final bool showListenerInfo;

  /// 日志前缀，默认值为 '[Geb]'
  final String logPrefix;

  /// 自定义日志输出函数，用于替换默认的 debugPrint
  final void Function(String message)? customLogger;

  /// 事件类型过滤器，只记录指定类型的事件日志
  final List<String>? eventTypeFilter;

  /// 监听器ID过滤器，只记录指定监听器的日志
  final List<String>? listenerIdFilter;

  /// 创建日志配置
  ///
  /// [level] 日志级别，默认为 [GebLogLevel.info]
  /// [enabled] 是否启用日志，默认为 true
  /// [showTimestamp] 是否显示时间戳，默认为 true
  /// [showEventId] 是否显示事件ID，默认为 false
  /// [showPriority] 是否显示优先级，默认为 true
  /// [showEventData] 是否显示事件数据，默认为 false
  /// [showListenerInfo] 是否显示监听器信息，默认为 true
  /// [logPrefix] 日志前缀，默认为 '[Geb]'
  /// [customLogger] 自定义日志函数，可选
  /// [eventTypeFilter] 事件类型过滤器，可选
  /// [listenerIdFilter] 监听器ID过滤器，可选
  const GebLogConfig({
    this.level = GebLogLevel.info,
    this.enabled = true,
    this.showTimestamp = true,
    this.showEventId = false,
    this.showPriority = true,
    this.showEventData = false,
    this.showListenerInfo = true,
    this.logPrefix = '[Geb]',
    this.customLogger,
    this.eventTypeFilter,
    this.listenerIdFilter,
  });

  /// 默认配置：info级别，显示基本信息
  static const GebLogConfig defaultConfig = GebLogConfig();

  /// 调试配置：debug级别，显示事件ID和数据
  static const GebLogConfig debugConfig = GebLogConfig(
    level: GebLogLevel.debug,
    showEventId: true,
    showEventData: true,
  );

  /// 生产配置：error级别，不显示敏感信息
  static const GebLogConfig productionConfig = GebLogConfig(
    level: GebLogLevel.error,
    showEventData: false,
    showListenerInfo: false,
  );

  /// 静默配置：禁用所有日志
  static const GebLogConfig silentConfig = GebLogConfig(
    enabled: false,
    level: GebLogLevel.none,
  );

  /// 创建一个新的配置，可选择性覆盖原有配置
  GebLogConfig copyWith({
    GebLogLevel? level,
    bool? enabled,
    bool? showTimestamp,
    bool? showEventId,
    bool? showPriority,
    bool? showEventData,
    bool? showListenerInfo,
    String? logPrefix,
    void Function(String message)? customLogger,
    List<String>? eventTypeFilter,
    List<String>? listenerIdFilter,
  }) {
    return GebLogConfig(
      level: level ?? this.level,
      enabled: enabled ?? this.enabled,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      showEventId: showEventId ?? this.showEventId,
      showPriority: showPriority ?? this.showPriority,
      showEventData: showEventData ?? this.showEventData,
      showListenerInfo: showListenerInfo ?? this.showListenerInfo,
      logPrefix: logPrefix ?? this.logPrefix,
      customLogger: customLogger ?? this.customLogger,
      eventTypeFilter: eventTypeFilter ?? this.eventTypeFilter,
      listenerIdFilter: listenerIdFilter ?? this.listenerIdFilter,
    );
  }
}

@Deprecated('Use GebLogConfig instead. Will be removed in a future version')
typedef GlobalEventLogConfig = GebLogConfig;

/// 全局事件总线的日志管理器。
///
/// 提供静态方法用于记录事件发送、接收、监听器操作等日志信息。
/// 日志行为由 [GebLogConfig] 控制。
class GebLogger {
  static GebLogConfig _config = GebLogConfig.defaultConfig;

  /// 设置日志配置
  static void setConfig(GebLogConfig config) {
    _config = config;
  }

  /// 当前日志配置
  static GebLogConfig get config => _config;

  /// 记录事件发送日志
  ///
  /// [type] 事件类型
  /// [priority] 事件优先级
  /// [eventId] 事件ID，可选
  /// [data] 事件数据，可选
  static void logEventSent(
    String type,
    GebPriority priority, {
    String? eventId,
    dynamic data,
  }) {
    if (!_config.enabled || !_shouldLog(GebLogLevel.info)) return;
    if (_config.eventTypeFilter != null && !_config.eventTypeFilter!.contains(type)) {
      return;
    }

    final message = _buildEventMessage(
      '发送事件',
      type,
      priority,
      eventId: eventId,
      data: data,
    );
    _output(message);
  }

  /// 记录事件接收日志
  ///
  /// [type] 事件类型
  /// [listenerId] 监听器ID
  /// [priority] 事件优先级
  /// [eventId] 事件ID，可选
  static void logEventReceived(
    String type,
    String listenerId,
    GebPriority priority, {
    String? eventId,
  }) {
    if (!_config.enabled || !_shouldLog(GebLogLevel.info)) return;
    if (_config.eventTypeFilter != null && !_config.eventTypeFilter!.contains(type)) {
      return;
    }
    if (_config.listenerIdFilter != null && !_config.listenerIdFilter!.contains(listenerId)) {
      return;
    }

    final message = _buildEventMessage(
      '接收事件',
      type,
      priority,
      eventId: eventId,
      listenerId: listenerId,
    );
    _output(message);
  }

  /// 记录监听器操作日志（添加/移除）
  ///
  /// [operation] 操作类型，如 '添加'、'移除'
  /// [listenerId] 监听器ID
  /// [eventTypes] 监听的事件类型列表，可选
  static void logListenerOperation(
    String operation,
    String listenerId, {
    List<String>? eventTypes,
  }) {
    if (!_config.enabled || !_shouldLog(GebLogLevel.info) || !_config.showListenerInfo) {
      return;
    }
    if (_config.listenerIdFilter != null && !_config.listenerIdFilter!.contains(listenerId)) {
      return;
    }

    final buffer = StringBuffer();
    buffer.write(_config.logPrefix);

    if (_config.showTimestamp) {
      buffer.write(' [${DateTime.now().toIso8601String()}]');
    }

    buffer.write(' $operation监听器: $listenerId');

    if (eventTypes != null && eventTypes.isNotEmpty) {
      buffer.write(' (事件类型: ${eventTypes.join(", ")})');
    }

    _output(buffer.toString());
  }

  /// 记录错误日志
  ///
  /// [message] 错误消息
  /// [error] 错误对象，可选
  /// [context] 上下文信息，可选
  static void logError(String message, {Object? error, String? context}) {
    if (!_config.enabled || !_shouldLog(GebLogLevel.error)) return;

    final buffer = StringBuffer();
    buffer.write(_config.logPrefix);

    if (_config.showTimestamp) {
      buffer.write(' [${DateTime.now().toIso8601String()}]');
    }

    buffer.write(' [ERROR]');

    if (context != null) {
      buffer.write(' [$context]');
    }

    buffer.write(' $message');

    if (error != null) {
      buffer.write(' - $error');
    }

    _output(buffer.toString());
  }

  /// 记录警告日志
  ///
  /// [message] 警告消息
  /// [context] 上下文信息，可选
  static void logWarning(String message, {String? context}) {
    if (!_config.enabled || !_shouldLog(GebLogLevel.warning)) return;

    final buffer = StringBuffer();
    buffer.write(_config.logPrefix);

    if (_config.showTimestamp) {
      buffer.write(' [${DateTime.now().toIso8601String()}]');
    }

    buffer.write(' [WARNING]');

    if (context != null) {
      buffer.write(' [$context]');
    }

    buffer.write(' $message');

    _output(buffer.toString());
  }

  /// 记录调试日志
  ///
  /// [message] 调试消息
  /// [context] 上下文信息，可选
  static void logDebug(String message, {String? context}) {
    if (!_config.enabled || !_shouldLog(GebLogLevel.debug)) return;

    final buffer = StringBuffer();
    buffer.write(_config.logPrefix);

    if (_config.showTimestamp) {
      buffer.write(' [${DateTime.now().toIso8601String()}]');
    }

    buffer.write(' [DEBUG]');

    if (context != null) {
      buffer.write(' [$context]');
    }

    buffer.write(' $message');

    _output(buffer.toString());
  }

  /// 构建事件日志消息
  static String _buildEventMessage(
    String action,
    String type,
    GebPriority priority, {
    String? eventId,
    dynamic data,
    String? listenerId,
  }) {
    final buffer = StringBuffer();
    buffer.write(_config.logPrefix);

    if (_config.showTimestamp) {
      buffer.write(' [${DateTime.now().toIso8601String()}]');
    }

    buffer.write(' $action: $type');

    if (_config.showPriority) {
      buffer.write(' (优先级: ${priority.name})');
    }

    if (_config.showEventId && eventId != null) {
      buffer.write(' [ID: $eventId]');
    }

    if (listenerId != null && _config.showListenerInfo) {
      buffer.write(' [监听器: $listenerId]');
    }

    if (_config.showEventData && data != null) {
      buffer.write(' [数据: $data]');
    }

    return buffer.toString();
  }

  /// 判断指定级别的日志是否应该输出
  static bool _shouldLog(GebLogLevel level) {
    return _config.level.index >= level.index;
  }

  /// 输出日志消息
  static void _output(String message) {
    if (_config.customLogger != null) {
      _config.customLogger!(message);
    } else {
      debugPrint(message);
    }
  }
}

@Deprecated('Use GebLogger instead. Will be removed in a future version')
typedef GlobalEventLogger = GebLogger;
