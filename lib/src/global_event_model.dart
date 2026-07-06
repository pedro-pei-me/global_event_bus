/// 事件优先级枚举，用于控制事件处理顺序。
///
/// 优先级从低到高：[low] < [normal] < [high] < [critical]
/// 在批量模式下，高优先级事件会先于低优先级事件被处理。
enum GebPriority {
  /// 低优先级，用于非紧急事件
  low(0),

  /// 正常优先级，默认值
  normal(1),

  /// 高优先级，用于重要事件
  high(2),

  /// 最高优先级，用于关键事件
  critical(3);

  const GebPriority(this.value);

  /// 优先级数值，数值越大优先级越高
  final int value;
}

@Deprecated('Use GebPriority instead. Will be removed in a future version')
typedef EventPriority = GebPriority;

/// 全局事件总线的统计信息类。
///
/// 记录事件发送和接收的统计数据，用于监控和性能分析。
class GebStats {
  /// 已发送的事件总数
  int totalEventsSent = 0;

  /// 已接收的事件总数
  int totalEventsReceived = 0;

  /// 按事件类型统计的发送次数
  final Map<String, int> eventTypeCount = {};

  /// 最后一次事件发送的时间
  DateTime? lastEventTime;

  /// 记录已发送的事件
  ///
  /// [type] 事件类型
  void recordSentEvent(String type) {
    totalEventsSent++;
    eventTypeCount[type] = (eventTypeCount[type] ?? 0) + 1;
    lastEventTime = DateTime.now();
  }

  /// 记录已接收的事件
  void recordReceivedEvent() {
    totalEventsReceived++;
  }
}

@Deprecated('Use GebStats instead. Will be removed in a future version')
typedef EventStats = GebStats;

/// 所有事件的基类，定义事件的通用属性。
///
/// 包含事件类型、时间戳、事件ID、优先级和元数据。
abstract class GebBaseEvent {
  /// 事件类型，用于区分不同种类的事件
  final String type;

  /// 事件创建时间
  final DateTime timestamp;

  /// 事件唯一标识符
  final String eventId;

  /// 事件优先级
  final GebPriority priority;

  /// 事件元数据，可存储额外信息
  final Map<String, dynamic>? metadata;

  /// 创建一个基础事件
  ///
  /// [type] 事件类型，必填
  /// [priority] 事件优先级，默认为 [GebPriority.normal]
  /// [metadata] 事件元数据，可选
  GebBaseEvent({
    required this.type,
    this.priority = GebPriority.normal,
    this.metadata,
  })  : timestamp = DateTime.now(),
        eventId = _generateEventId();

  static int _counter = 0;

  /// 生成唯一的事件ID
  static String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
  }

  @override
  String toString() {
    return 'GebEvent{type: $type, priority: $priority, timestamp: $timestamp}';
  }
}

@Deprecated('Use GebBaseEvent instead. Will be removed in a future version')
typedef BaseGlobalEvent = GebBaseEvent;

/// 带类型数据的事件类，继承自 [GebBaseEvent]。
///
/// 使用泛型 [T] 来指定事件携带的数据类型，提供编译时类型安全。
class GebEvent<T> extends GebBaseEvent {
  /// 事件携带的数据，类型由泛型 [T] 指定
  final T data;

  /// 创建一个带数据的事件
  ///
  /// [type] 事件类型，必填
  /// [data] 事件数据，必填，类型为 [T]
  /// [priority] 事件优先级，默认为 [GebPriority.normal]
  /// [metadata] 事件元数据，可选
  GebEvent({
    required super.type,
    required this.data,
    super.priority,
    super.metadata,
  });

  @override
  String toString() {
    return 'GebEvent{type: $type, data: $data, priority: $priority, timestamp: $timestamp}';
  }
}

@Deprecated('Use GebEvent<T> instead. Will be removed in a future version')
typedef GlobalEvent<T> = GebEvent<T>;

/// 事件历史记录配置类。
///
/// 用于配置事件历史记录的行为，包括是否启用和最大记录数。
class GebHistoryConfig {
  /// 是否启用事件历史记录
  final bool enabled;

  /// 历史记录的最大条数，超过后会自动删除最早的记录
  final int maxHistorySize;

  /// 创建历史记录配置
  ///
  /// [enabled] 是否启用，默认为 true
  /// [maxHistorySize] 最大记录数，默认为 100
  const GebHistoryConfig({
    this.enabled = true,
    this.maxHistorySize = 100,
  });

  /// 默认配置：启用，最大100条记录
  static const GebHistoryConfig defaultConfig = GebHistoryConfig();

  /// 禁用配置：不记录历史
  static const GebHistoryConfig disabled = GebHistoryConfig(enabled: false);

  /// 创建一个新的配置，可选择性覆盖原有配置
  GebHistoryConfig copyWith({
    bool? enabled,
    int? maxHistorySize,
  }) {
    return GebHistoryConfig(
      enabled: enabled ?? this.enabled,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
    );
  }
}

@Deprecated('Use GebHistoryConfig instead. Will be removed in a future version')
typedef EventHistoryConfig = GebHistoryConfig;

/// 事件历史记录管理器。
///
/// 负责记录、查询和管理事件历史，支持按类型、数量等多种方式查询。
class GebHistory {
  final List<GebBaseEvent> _events = [];
  GebHistoryConfig _config = GebHistoryConfig.defaultConfig;

  /// 更新历史记录配置
  ///
  /// 如果配置为禁用，会清空所有历史记录
  void configure(GebHistoryConfig config) {
    _config = config;
    if (!config.enabled) {
      clear();
    }
  }

  /// 当前配置
  GebHistoryConfig get config => _config;

  /// 添加事件到历史记录
  ///
  /// 如果历史记录已禁用，则不添加
  void addEvent(GebBaseEvent event) {
    if (!_config.enabled) return;

    _events.add(event);

    while (_events.length > _config.maxHistorySize) {
      _events.removeAt(0);
    }
  }

  /// 获取所有历史事件（不可修改）
  List<GebBaseEvent> get all => List.unmodifiable(_events);

  /// 获取所有历史事件，按时间倒序（不可修改）
  List<GebBaseEvent> get allReversed => List.unmodifiable(_events.reversed);

  /// 获取最近的 [count] 个事件，按时间倒序
  ///
  /// [count] 获取的事件数量，小于等于0时返回空列表
  List<GebBaseEvent> getRecent(int count) {
    if (count <= 0) return [];
    final start = _events.length - count;
    final recent = _events.sublist(start > 0 ? start : 0);
    return List.unmodifiable(recent.reversed);
  }

  /// 获取指定类型的所有历史事件
  ///
  /// [type] 事件类型
  List<GebBaseEvent> getByType(String type) {
    return List.unmodifiable(
      _events.where((event) => event.type == type),
    );
  }

  /// 获取指定类型最近的 [count] 个事件，按时间倒序
  ///
  /// [type] 事件类型
  /// [count] 获取的事件数量，默认为1
  List<GebBaseEvent> getRecentByType(String type, {int count = 1}) {
    if (count <= 0) return [];
    final events = _events.where((event) => event.type == type).toList();
    final start = events.length - count;
    final recent = events.sublist(start > 0 ? start : 0);
    return List.unmodifiable(recent.reversed);
  }

  /// 获取指定类型的最后一个事件
  ///
  /// [type] 事件类型，不存在时返回 null
  GebBaseEvent? getLastByType(String type) {
    for (var i = _events.length - 1; i >= 0; i--) {
      if (_events[i].type == type) {
        return _events[i];
      }
    }
    return null;
  }

  /// 获取所有已记录的事件类型
  List<String> get eventTypes {
    return _events.map((event) => event.type).toSet().toList();
  }

  /// 当前历史记录的事件数量
  int get count => _events.length;

  /// 检查是否存在指定类型的事件
  ///
  /// [type] 事件类型
  bool hasType(String type) {
    return _events.any((event) => event.type == type);
  }

  /// 清空所有历史记录
  void clear() {
    _events.clear();
  }

  /// 删除指定类型的所有历史事件
  ///
  /// [type] 要删除的事件类型
  void removeByType(String type) {
    _events.removeWhere((event) => event.type == type);
  }

  /// 删除指定事件ID的历史事件
  ///
  /// [eventId] 事件ID
  void removeByEventId(String eventId) {
    _events.removeWhere((event) => event.eventId == eventId);
  }
}

@Deprecated('Use GebHistory instead. Will be removed in a future version')
typedef EventHistory = GebHistory;
