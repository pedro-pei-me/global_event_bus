import 'package:flutter/foundation.dart';

import 'global_event_model.dart';

/// 日志级别枚举
///
/// 用于控制日志输出的详细程度，从最简略到最详细依次为：
/// - [none]: 不输出任何日志，完全静默
/// - [error]: 只输出错误信息，适用于生产环境
/// - [warning]: 输出警告和错误，适用于监控关键问题
/// - [info]: 输出信息、警告和错误，适用于一般调试
/// - [debug]: 输出所有日志包括调试信息，适用于开发调试
///
/// 示例：
/// ```dart
/// // 只记录错误
/// final config = GlobalEventLogConfig(level: EventLogLevel.error);
///
/// // 记录所有调试信息
/// final debugConfig = GlobalEventLogConfig(level: EventLogLevel.debug);
/// ```
enum EventLogLevel {
  /// 不输出任何日志，完全静默模式
  none,

  /// 只输出错误级别日志
  /// 适用于生产环境，只关注系统异常
  error,

  /// 输出警告和错误级别日志
  /// 适用于监控需要关注的潜在问题
  warning,

  /// 输出信息、警告和错误级别日志
  /// 适用于一般调试，显示常规操作信息
  info,

  /// 输出所有级别的日志包括调试信息
  /// 适用于开发调试，显示最详细的信息
  debug,
}

/// 全局事件日志配置类
///
/// 用于配置全局事件系统的日志输出行为，包括日志级别、显示内容、过滤器等。
/// 提供了多种预设配置（[defaultConfig]、[debugConfig]、[productionConfig]、[silentConfig]），
/// 也可以自定义配置。
///
/// 主要功能：
/// - 控制日志级别和输出开关
/// - 配置日志显示内容（时间戳、事件ID、优先级、数据等）
/// - 支持自定义日志输出函数
/// - 提供事件类型和监听器ID过滤器
///
/// 示例：
/// ```dart
/// // 使用预设的调试配置
/// globalEventBus.configureLogging(GlobalEventLogConfig.debugConfig);
///
/// // 自定义配置
/// final config = GlobalEventLogConfig(
///   level: EventLogLevel.warning,
///   showEventData: true,
///   eventTypeFilter: ['user_login', 'user_logout'],
/// );
/// globalEventBus.configureLogging(config);
/// ```
class GlobalEventLogConfig {
  /// 日志级别
  ///
  /// 默认值: [EventLogLevel.info]
  /// 控制输出哪些级别的日志信息。级别越高，输出的日志越详细。
  final EventLogLevel level;

  /// 是否启用日志
  ///
  /// 默认值: true
  /// 总开关，控制是否输出任何日志。设为 false 时完全不输出日志。
  final bool enabled;

  /// 是否显示时间戳
  ///
  /// 默认值: true
  /// 控制日志中是否包含时间戳信息，格式为 ISO 8601。
  final bool showTimestamp;

  /// 是否显示事件ID
  ///
  /// 默认值: false
  /// 控制日志中是否显示事件的唯一标识符，用于追踪特定事件实例。
  final bool showEventId;

  /// 是否显示优先级
  ///
  /// 默认值: true
  /// 控制日志中是否显示事件的优先级信息。
  final bool showPriority;

  /// 是否显示事件数据
  ///
  /// 默认值: false
  /// 控制日志中是否显示事件携带的数据内容。
  /// 注意：显示事件数据可能会暴露敏感信息，生产环境建议关闭。
  final bool showEventData;

  /// 是否显示监听器信息
  ///
  /// 默认值: true
  /// 控制日志中是否显示处理事件的监听器信息。
  final bool showListenerInfo;

  /// 自定义日志前缀
  ///
  /// 默认值: '[GlobalEvent]'
  /// 用于标识全局事件系统的日志，便于在混合日志中识别。
  final String logPrefix;

  /// 自定义日志输出函数
  ///
  /// 默认值: null
  /// 当为 null 时使用系统默认的 debugPrint 函数。
  /// 可以自定义为文件输出、网络上传、第三方日志服务等。
  ///
  /// 示例：
  /// ```dart
  /// final config = GlobalEventLogConfig(
  ///   customLogger: (message) {
  ///     // 写入文件
  ///     logFile.write(message);
  ///     // 或发送到远程日志服务
  ///     sendToRemoteLogger(message);
  ///   },
  /// );
  /// ```
  final void Function(String message)? customLogger;

  /// 事件类型过滤器
  ///
  /// 默认值: null
  /// 当不为 null 时，只记录指定类型的事件日志。
  /// 用于减少日志量，专注于特定事件类型的调试。
  ///
  /// 示例：
  /// ```dart
  /// // 只记录用户相关事件的日志
  /// eventTypeFilter: ['user_login', 'user_logout', 'user_update'],
  /// ```
  final List<String>? eventTypeFilter;

  /// 监听器ID过滤器
  ///
  /// 默认值: null
  /// 当不为 null 时，只记录指定监听器的日志。
  /// 用于专注于特定监听器的行为调试。
  ///
  /// 示例：
  /// ```dart
  /// // 只记录特定监听器的日志
  /// listenerIdFilter: ['my_widget_listener', 'auth_listener'],
  /// ```
  final List<String>? listenerIdFilter;

  /// 构造函数
  ///
  /// 所有参数都有默认值，可以根据需要选择性配置。
  /// 建议使用命名参数只覆盖需要修改的配置项。
  const GlobalEventLogConfig({
    this.level = EventLogLevel.info, // 默认信息级别
    this.enabled = true, // 默认启用日志
    this.showTimestamp = true, // 默认显示时间戳
    this.showEventId = false, // 默认不显示事件ID
    this.showPriority = true, // 默认显示优先级
    this.showEventData = false, // 默认不显示事件数据
    this.showListenerInfo = true, // 默认显示监听器信息
    this.logPrefix = '[GlobalEvent]', // 默认日志前缀
    this.customLogger, // 默认为null，使用系统日志
    this.eventTypeFilter, // 默认为null，不过滤事件类型
    this.listenerIdFilter, // 默认为null，不过滤监听器
  });

  /// 创建默认配置
  ///
  /// 使用所有默认值的配置实例，等同于直接调用无参构造函数。
  /// 适合快速开始使用，不需要手动配置任何参数。
  static const GlobalEventLogConfig defaultConfig = GlobalEventLogConfig();

  /// 创建调试配置
  ///
  /// 适合开发调试时使用，显示更多详细信息。
  /// 特点：
  /// - 日志级别为 [EventLogLevel.debug]，显示所有级别日志
  /// - 显示事件ID，便于追踪特定事件
  /// - 显示事件数据，便于查看事件内容
  ///
  /// 示例：
  /// ```dart
  /// globalEventBus.configureLogging(GlobalEventLogConfig.debugConfig);
  /// ```
  static const GlobalEventLogConfig debugConfig = GlobalEventLogConfig(
    level: EventLogLevel.debug, // 显示所有级别日志
    showEventId: true, // 显示事件ID
    showEventData: true, // 显示事件数据
  );

  /// 创建生产环境配置
  ///
  /// 适合生产环境使用，只显示关键错误信息。
  /// 特点：
  /// - 日志级别为 [EventLogLevel.error]，只显示错误
  /// - 不显示事件数据，避免暴露敏感信息
  /// - 不显示监听器详情，减少日志输出
  ///
  /// 示例：
  /// ```dart
  /// globalEventBus.configureLogging(GlobalEventLogConfig.productionConfig);
  /// ```
  static const GlobalEventLogConfig productionConfig = GlobalEventLogConfig(
    level: EventLogLevel.error, // 只显示错误级别
    showEventData: false, // 不显示敏感数据
    showListenerInfo: false, // 不显示监听器详情
  );

  /// 创建静默配置
  ///
  /// 完全关闭日志输出，适用于不需要任何日志的场景。
  ///
  /// 示例：
  /// ```dart
  /// globalEventBus.configureLogging(GlobalEventLogConfig.silentConfig);
  /// ```
  static const GlobalEventLogConfig silentConfig = GlobalEventLogConfig(
    enabled: false, // 禁用日志
    level: EventLogLevel.none, // 不输出任何级别
  );

  /// 复制并修改配置
  ///
  /// 基于当前配置创建新的配置实例，只修改指定的属性。
  /// 使用 copyWith 模式，保持配置的不可变性。
  ///
  /// 参数：
  /// - 所有参数均为可选，不传则保持原值
  ///
  /// 返回值：
  /// - 新的 [GlobalEventLogConfig] 实例
  ///
  /// 示例：
  /// ```dart
  /// final baseConfig = GlobalEventLogConfig.defaultConfig;
  ///
  /// // 基于基础配置，只启用事件数据
  /// final configWithData = baseConfig.copyWith(showEventData: true);
  ///
  /// // 基于基础配置，修改日志级别和过滤
  /// final customConfig = baseConfig.copyWith(
  ///   level: EventLogLevel.warning,
  ///   eventTypeFilter: ['user_login'],
  /// );
  /// ```
  GlobalEventLogConfig copyWith({
    EventLogLevel? level,
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
    return GlobalEventLogConfig(
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

/// 全局事件日志器
///
/// 提供静态方法来记录全局事件系统的各种日志信息。
/// 该类是内部使用的日志工具，通常不需要直接调用。
/// 通过 [GlobalEventLogConfig] 配置日志行为。
///
/// 日志类型包括：
/// - 事件发送日志：记录事件的发送情况
/// - 事件接收日志：记录监听器接收事件的情况
/// - 监听器操作日志：记录监听器的添加、移除等操作
/// - 错误/警告/调试日志：记录系统运行状态
class GlobalEventLogger {
  /// 当前日志配置
  static GlobalEventLogConfig _config = GlobalEventLogConfig.defaultConfig;

  /// 设置日志配置
  ///
  /// 更新全局日志器的配置，影响后续所有日志输出。
  ///
  /// 参数：
  /// - [config] 新的日志配置实例
  static void setConfig(GlobalEventLogConfig config) {
    _config = config;
  }

  /// 获取当前配置
  ///
  /// 返回当前正在使用的日志配置实例。
  static GlobalEventLogConfig get config => _config;

  /// 记录事件发送日志
  ///
  /// 当事件被发送时调用，记录事件的类型、优先级、ID和数据等信息。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [priority] 事件优先级
  /// - [eventId] 可选的事件唯一标识符
  /// - [data] 可选的事件数据
  static void logEventSent(
    String type,
    EventPriority priority, {
    String? eventId,
    dynamic data,
  }) {
    if (!_config.enabled || !_shouldLog(EventLogLevel.info)) return;
    if (_config.eventTypeFilter != null &&
        !_config.eventTypeFilter!.contains(type)) {
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
  /// 当监听器接收到事件时调用，记录事件的类型、监听器ID和优先级等信息。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  /// - [listenerId] 监听器的唯一标识符
  /// - [priority] 事件优先级
  /// - [eventId] 可选的事件唯一标识符
  static void logEventReceived(
    String type,
    String listenerId,
    EventPriority priority, {
    String? eventId,
  }) {
    if (!_config.enabled || !_shouldLog(EventLogLevel.info)) return;
    if (_config.eventTypeFilter != null &&
        !_config.eventTypeFilter!.contains(type)) {
      return;
    }
    if (_config.listenerIdFilter != null &&
        !_config.listenerIdFilter!.contains(listenerId)) {
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

  /// 记录监听器操作日志
  ///
  /// 当监听器被添加或移除时调用，记录监听器的操作类型和相关信息。
  ///
  /// 参数：
  /// - [operation] 操作类型描述，如 '添加'、'移除'
  /// - [listenerId] 监听器的唯一标识符
  /// - [eventTypes] 可选的监听器关注的事件类型列表
  static void logListenerOperation(
    String operation,
    String listenerId, {
    List<String>? eventTypes,
  }) {
    if (!_config.enabled ||
        !_shouldLog(EventLogLevel.info) ||
        !_config.showListenerInfo) {
      return;
    }
    if (_config.listenerIdFilter != null &&
        !_config.listenerIdFilter!.contains(listenerId)) {
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
  /// 当事件系统发生错误时调用，记录错误信息和上下文。
  ///
  /// 参数：
  /// - [message] 错误描述信息
  /// - [error] 可选的错误对象
  /// - [context] 可选的错误发生上下文，如方法名或模块名
  static void logError(String message, {Object? error, String? context}) {
    if (!_config.enabled || !_shouldLog(EventLogLevel.error)) return;

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
  /// 当事件系统出现潜在问题时调用，记录警告信息和上下文。
  ///
  /// 参数：
  /// - [message] 警告描述信息
  /// - [context] 可选的警告发生上下文
  static void logWarning(String message, {String? context}) {
    if (!_config.enabled || !_shouldLog(EventLogLevel.warning)) return;

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
  /// 用于开发调试，记录详细的系统运行信息。
  /// 只在日志级别为 [EventLogLevel.debug] 时输出。
  ///
  /// 参数：
  /// - [message] 调试描述信息
  /// - [context] 可选的调试发生上下文
  static void logDebug(String message, {String? context}) {
    if (!_config.enabled || !_shouldLog(EventLogLevel.debug)) return;

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

  /// 构建事件消息
  ///
  /// 内部方法，根据当前配置构建格式化的事件日志消息。
  ///
  /// 参数：
  /// - [action] 动作描述，如 '发送事件'、'接收事件'
  /// - [type] 事件类型标识符
  /// - [priority] 事件优先级
  /// - [eventId] 可选的事件唯一标识符
  /// - [data] 可选的事件数据
  /// - [listenerId] 可选的监听器ID
  static String _buildEventMessage(
    String action,
    String type,
    EventPriority priority, {
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

  /// 检查是否应该记录日志
  ///
  /// 内部方法，根据当前配置的日志级别判断是否应该输出指定级别的日志。
  ///
  /// 参数：
  /// - [level] 要检查的日志级别
  ///
  /// 返回值：
  /// - `true` 表示应该记录该级别的日志
  /// - `false` 表示不应该记录
  static bool _shouldLog(EventLogLevel level) {
    return _config.level.index >= level.index;
  }

  /// 输出日志
  ///
  /// 内部方法，将构建好的日志消息输出到目标位置。
  /// 如果配置了自定义日志输出函数则使用自定义函数，否则使用 debugPrint。
  ///
  /// 参数：
  /// - [message] 已构建好的日志消息
  static void _output(String message) {
    if (_config.customLogger != null) {
      _config.customLogger!(message);
    } else {
      debugPrint(message);
    }
  }
}
