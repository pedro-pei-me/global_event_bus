/// 事件优先级枚举
///
/// 定义事件的优先级级别，用于控制事件的处理顺序。
/// 优先级越高的事件会被越早处理。
///
/// 优先级从低到高依次为：
/// - [low]: 低优先级，用于非紧急的后台任务或数据同步
/// - [normal]: 普通优先级，默认级别，用于大多数常规事件
/// - [high]: 高优先级，用于重要的用户交互或UI更新
/// - [critical]: 关键优先级，用于必须立即处理的关键事件
///
/// 示例：
/// ```dart
/// // 发送高优先级事件
/// globalEventBus.sendEvent<String>(
///   type: 'user_action',
///   data: 'button_click',
///   priority: EventPriority.high,
/// );
/// ```
enum EventPriority {
  /// 低优先级：用于非紧急的后台任务或数据同步
  low(0),

  /// 普通优先级：默认级别，用于大多数常规事件
  normal(1),

  /// 高优先级：用于重要的用户交互或UI更新
  high(2),

  /// 关键优先级：用于必须立即处理的关键事件
  critical(3);

  const EventPriority(this.value);

  /// 优先级的数值表示，数值越大优先级越高
  final int value;
}

/// 事件统计信息类
///
/// 用于跟踪和记录事件系统的运行统计数据，包括发送和接收的事件数量、
/// 事件类型分布以及最后事件时间等信息。
///
/// 该实例通常由 [GlobalEventManager] 内部管理，
/// 可通过 [GlobalEventBus.stats] 属性访问。
///
/// 示例：
/// ```dart
/// final stats = globalEventBus.stats;
/// print('已发送事件: ${stats.totalEventsSent}');
/// print('已接收事件: ${stats.totalEventsReceived}');
/// print('事件类型分布: ${stats.eventTypeCount}');
/// ```
class EventStats {
  /// 已发送的事件总数
  int totalEventsSent = 0;

  /// 已接收的事件总数
  int totalEventsReceived = 0;

  /// 各事件类型的发送次数统计
  ///
  /// Key 为事件类型标识符，Value 为该类型事件的发送次数
  final Map<String, int> eventTypeCount = {};

  /// 最后一个事件的发生时间
  DateTime? lastEventTime;

  /// 记录一次事件发送
  ///
  /// 内部方法，用于更新发送统计信息。
  /// 每次发送事件时由事件管理器自动调用。
  ///
  /// 参数：
  /// - [type] 事件类型标识符
  void recordSentEvent(String type) {
    totalEventsSent++;
    eventTypeCount[type] = (eventTypeCount[type] ?? 0) + 1;
    lastEventTime = DateTime.now();
  }

  /// 记录一次事件接收
  ///
  /// 内部方法，用于更新接收统计信息。
  /// 每次监听器接收到事件时自动调用。
  void recordReceivedEvent() {
    totalEventsReceived++;
  }
}

/// 基础事件类
///
/// 所有全局事件的抽象基类，定义了事件的基本属性和行为。
/// 每个事件实例都包含类型标识、时间戳、唯一ID、优先级和可选的元数据。
///
/// 该类为抽象类，不能直接实例化。请使用 [GlobalEvent<T>] 来创建具体的事件实例。
///
/// 主要属性：
/// - [type]: 事件类型标识符，用于区分不同的事件
/// - [timestamp]: 事件创建的时间戳
/// - [eventId]: 事件的唯一标识符
/// - [priority]: 事件的优先级
/// - [metadata]: 可选的元数据，用于传递额外信息
abstract class BaseGlobalEvent {
  /// 事件类型标识符
  ///
  /// 用于区分不同的事件类型，监听器可以根据此属性过滤事件。
  /// 建议使用有意义的字符串，如 'user_login'、'data_updated' 等。
  final String type;

  /// 事件创建的时间戳
  ///
  /// 自动设置为事件实例化时的当前时间。
  final DateTime timestamp;

  /// 事件的唯一标识符
  ///
  /// 由系统自动生成，格式为 "时间戳_计数器"，
  /// 用于追踪和调试特定事件实例。
  final String eventId;

  /// 事件的优先级
  ///
  /// 决定事件在批量处理时的执行顺序。优先级越高的事件越先被处理。
  /// 默认值为 [EventPriority.normal]。
  final EventPriority priority;

  /// 事件的元数据
  ///
  /// 可选的键值对集合，用于传递额外的上下文信息。
  /// 例如：{'source': 'login_page', 'version': '1.0'}
  final Map<String, dynamic>? metadata;

  /// 创建基础事件实例
  ///
  /// 参数：
  /// - [type] 事件类型标识符（必填）
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  BaseGlobalEvent({
    required this.type,
    this.priority = EventPriority.normal,
    this.metadata,
  })  : timestamp = DateTime.now(),
        eventId = _generateEventId();

  /// 事件ID计数器
  ///
  /// 用于生成唯一的事件ID，确保同一毫秒内的事件也有不同的ID。
  static int _counter = 0;

  /// 生成唯一的事件ID
  ///
  /// 使用毫秒时间戳和递增计数器组合生成唯一标识符。
  /// 格式："{millisecondsSinceEpoch}_{counter}"
  static String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
  }

  @override
  String toString() {
    return 'GlobalEvent{type: $type, priority: $priority, timestamp: $timestamp}';
  }
}

/// 泛型全局事件类
///
/// 继承自 [BaseGlobalEvent]，添加了类型安全的数据承载能力。
/// 这是实际使用中最常用的事件类型，可以携带任意类型的数据。
///
/// 泛型参数：
/// - [T]: 事件数据的类型，可以是任何 Dart 类型
///
/// 示例：
/// ```dart
/// // 创建字符串类型的事件
/// final stringEvent = GlobalEvent<String>(
///   type: 'message',
///   data: 'Hello World',
///   priority: EventPriority.high,
/// );
///
/// // 创建复杂对象类型的事件
/// final userEvent = GlobalEvent<UserInfo>(
///   type: 'user_login',
///   data: UserInfo(id: '123', name: 'John'),
///   metadata: {'source': 'login_page'},
/// );
/// ```
class GlobalEvent<T> extends BaseGlobalEvent {
  /// 事件携带的数据
  ///
  /// 类型为泛型 T，可以是任何 Dart 类型。
  /// 这是事件的主要内容，用于在应用的不同模块之间传递信息。
  final T data;

  /// 创建泛型全局事件实例
  ///
  /// 参数：
  /// - [type] 事件类型标识符（必填）
  /// - [data] 事件携带的数据（必填）
  /// - [priority] 事件优先级，默认为 [EventPriority.normal]
  /// - [metadata] 可选的事件元数据
  GlobalEvent({
    required super.type,
    required this.data,
    super.priority,
    super.metadata,
  });

  @override
  String toString() {
    return 'GlobalEvent{type: $type, data: $data, priority: $priority, timestamp: $timestamp}';
  }
}
